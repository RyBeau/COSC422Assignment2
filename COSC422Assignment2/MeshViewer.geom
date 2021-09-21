#version 400

layout (triangles_adjacency) in;
layout (triangle_strip , max_vertices = 27) out;

uniform mat4 mvMatrix;
uniform mat4 mvpMatrix;
uniform vec4 lightPos;

in vec3 vertNormal[];
out vec3 normalVec;

out vec3 oPosition;
out vec2 TexCoord;
out vec3 lgtVec;
out vec4 normalEye;
out vec4 halfVec;

flat out int edgeVertex;

vec4 faceNormal;

float d1_c = 0.5;
float d2_c = 1;

float d1_s = 0.1;
float d2_s = 3;

float PI = 3.14159265;
float T = cos(50 * PI / 180.0);

/*
    Calculates all the vectors needed for the lighting calculations in the fragment shader.
*/
vec4 calculateFaceNormal(int targetIndex, int secondIndex, int thirdIndex){
    vec3 vector1 = gl_in[targetIndex].gl_Position.xyz - gl_in[thirdIndex].gl_Position.xyz;
    vec3 vector2 = gl_in[secondIndex].gl_Position.xyz - gl_in[thirdIndex].gl_Position.xyz;

    return vec4(normalize(cross(vector1, vector2)), 0);
}

void addCreaseEdge(vec4 a, vec4 b, vec4 n1, vec4 n2){
    vec4 u = normalize(b - a);
    vec4 v = normalize(n1 + n2);
    vec4 w = vec4(normalize(cross(vec3(u), vec3(v))), 0);

    vec4 p1 = a + d1_c * v + d2_c * w;
    vec4 p2 = a + d1_c * v - d2_c * w;
    vec4 q1 = b + d1_c * v + d2_c * w;
    vec4 q2 = b + d1_c * v + d2_c * w;
    edgeVertex = 1;
    gl_Position = mvpMatrix * p1;
    EmitVertex();
    gl_Position = mvpMatrix * p2;
    EmitVertex();
    gl_Position = mvpMatrix * q1;
    EmitVertex();
    gl_Position = mvpMatrix * q2;
    EmitVertex();
    edgeVertex = 0;
}

void addSilhoutteEdge(vec4 a, vec4 b, vec4 n1, vec4 n2){
    vec4 v = normalize(n1 + n2);
    vec4 p1 = a + d1_s * v;
    vec4 p2 = a + d2_s * v;
    vec4 q1 = b + d1_s * v;
    vec4 q2 = b + d2_s * v;

    edgeVertex = 1;
    gl_Position = mvpMatrix * p1;
    EmitVertex();
    gl_Position = mvpMatrix * p2;
    EmitVertex();
    gl_Position = mvpMatrix * q1;
    EmitVertex();
    gl_Position = mvpMatrix * q2;
    EmitVertex();
    edgeVertex = 0;
}

/*
    Calculates all the vectors needed for the lighting calculations in the fragment shader.
*/
void lightingCalculations(int index){
    if (index == 0 || index == 2 || index == 4){
        vec4 adjFaceNormal = calculateFaceNormal(index, index + 1, (index + 2) % 6);
        if ((mvpMatrix * faceNormal).z > 0 && (mvpMatrix * adjFaceNormal).z < 0){
            addSilhoutteEdge(gl_in[index].gl_Position, gl_in[(index + 2) % 6].gl_Position, faceNormal, adjFaceNormal);
        } else if (dot(faceNormal, adjFaceNormal) < T){
            addCreaseEdge(gl_in[index].gl_Position, gl_in[(index + 2) % 6].gl_Position, faceNormal, adjFaceNormal);
        }
    }
    vec4 posnEye = mvMatrix * gl_in[index].gl_Position;
    lgtVec = normalize(lightPos.xyz - posnEye.xyz);
    vec4 viewVec = normalize(vec4(-posnEye.xyz, 0));
}


void main(){
    edgeVertex = 0;
    faceNormal = calculateFaceNormal(0, 2, 4);
	for(int i = 0; i < gl_in.length(); i++)
    {
        lightingCalculations(i);
        normalVec = vertNormal[i];
        switch(i) {
            case 0:
                TexCoord.s = 0.0;
                TexCoord.t = 0.0;
                break;
            case 2:
                TexCoord.s = 0.5;
                TexCoord.t = 0.0;


                break;
            case 4:
                TexCoord.s = 0.25;
                TexCoord.t = 0.5;
                break;
            default:
                break;
        }
        gl_Position = mvpMatrix * gl_in[i].gl_Position;
        EmitVertex();
    }
}