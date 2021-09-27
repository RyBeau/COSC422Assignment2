#version 400

layout (triangles_adjacency) in;
layout (triangle_strip , max_vertices = 27) out;

uniform mat4 mvMatrix;
uniform mat4 mvpMatrix;
uniform vec4 lightPos;

uniform int enableCrease;
uniform int enableSil;
uniform int enableFill;
uniform int enableOverlap;

//D1 and D2 in vector form
uniform vec2 creaseEdges;
uniform vec2 silEdges;

in vec3 vertNormal[];
out vec3 normalVec;

out vec3 oPosition;
out vec2 TexCoord;
out vec3 lgtVec;
out vec4 normalEye;
out vec4 halfVec;

flat out int edgeVertex;

vec4 faceNormal;

float PI = 3.14159265;
float T = cos(20 * PI / 180.0);

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
    vec4 w = vec4(normalize(cross(vec3(u.xyz), vec3(v.xyz))), 0);

    vec4 p1 = a + creaseEdges[0] * v + creaseEdges[1] * w;
    vec4 p2 = a + creaseEdges[0] * v - creaseEdges[1] * w;
    vec4 q1 = b + creaseEdges[0] * v + creaseEdges[1] * w;
    vec4 q2 = b + creaseEdges[0] * v - creaseEdges[1] * w;
    edgeVertex = 1;
    gl_Position = mvpMatrix * p1;
    EmitVertex();
    gl_Position = mvpMatrix * p2;
    EmitVertex();
    gl_Position = mvpMatrix * q1;
    EmitVertex();
    gl_Position = mvpMatrix * q2;
    EmitVertex();
    EndPrimitive();
}

void addSilhoutteEdge(vec4 a, vec4 b, vec4 n1, vec4 n2){
    vec4 v = normalize(n1 + n2);
   
   vec4 p1, p2, q1, q2;

    if (enableOverlap == 1){
        vec4 a_to_b = 3 * normalize(b - a);
        vec4 b_to_a = 3 * normalize(a - b);
        p1 = (a + b_to_a) + silEdges[0] * v;
        p2 = (a + b_to_a) + silEdges[1] * v;
        q1 = (b + a_to_b) + silEdges[0] * v;
        q2 = (b + a_to_b) + silEdges[1] * v;
    } else {
        p1 = a + silEdges[0] * v;
        p2 = a + silEdges[1] * v;
        q1 = b + silEdges[0] * v;
        q2 = b + silEdges[1] * v;
    }

    edgeVertex = 1;
    gl_Position = mvpMatrix * p1;
    EmitVertex();
    gl_Position = mvpMatrix * p2;
    EmitVertex();
    gl_Position = mvpMatrix * q1;
    EmitVertex();
    gl_Position = mvpMatrix * q2;
    EmitVertex();
    EndPrimitive();
}

void edgesCalculations(int index){
    vec4 adjFaceNormal = calculateFaceNormal(index, (index + 1) % 6, (index + 2) % 6);
    if (enableSil == 1) {
        if ((mvMatrix * faceNormal).z > 0 && (mvMatrix * adjFaceNormal).z < 0){
            addSilhoutteEdge(gl_in[index].gl_Position, gl_in[(index + 2) % 6].gl_Position, faceNormal, adjFaceNormal);
        }
    }

    if (enableCrease == 1) {
        if (dot(faceNormal, adjFaceNormal) < T){
            addCreaseEdge(gl_in[index].gl_Position, gl_in[(index + 2) % 6].gl_Position, faceNormal, adjFaceNormal);
        }
    }
}

/*
    Calculates all the vectors needed for the lighting calculations in the fragment shader.
*/
void lightingCalculations(int index){
    vec4 posnEye = mvMatrix * gl_in[index].gl_Position;
    lgtVec = normalize(lightPos.xyz - posnEye.xyz);
    vec4 viewVec = normalize(vec4(-posnEye.xyz, 0));
}



void main(){
    faceNormal = calculateFaceNormal(0, 2, 4);
    if (enableFill == 1) {
    	for(int i = 0; i < gl_in.length(); i++)
        {    
            if (i == 0 || i == 2 || i == 4){
                lightingCalculations(i);
            
                normalVec = vertNormal[i];
                if (i == 0) {
                    TexCoord.s = 0.0;
                    TexCoord.t = 0.0;
                }
                else if (i == 2) {
                    TexCoord.s = 1.0;
                    TexCoord.t = 0.5;
                }
                else if (i == 4) {
                    TexCoord.s = 0.0;
                    TexCoord.t = 1.0;
                }
                edgeVertex = 0;
                gl_Position = mvpMatrix * gl_in[i].gl_Position;
                EmitVertex();
                }
        }
        EndPrimitive();
    }

    for(int i = 0; i < gl_in.length(); i++)
    {
        if (i == 0 || i == 2 || i == 4){
            edgesCalculations(i);
        }
    }
}