#version 330

uniform sampler2D textureSampler[3];
uniform bool textureMode;

in vec2 TexCoord;
in vec3 oPosition;
in vec3 lgtVec;
in vec3 normalVec;
flat in int edgeVertex;

out vec4 outputColor;

/*
    Calculates the output colour for the fragment.
*/
vec4 calculateOutputColor(){
    vec4 diffOut;
    float diffTerm = dot(lgtVec, normalVec);
    if (textureMode){
        if (diffTerm < 0){
            diffOut = vec4(0.2, 0.2, 0.2, 1);
        } else if (diffTerm > 0.7) {
            diffOut = vec4(1, 1, 0, 1);
        } else {
            diffOut = vec4(0.5, 0.5, 0, 1);
        }
    } else {
        if (diffTerm < 0.0){
            diffOut = texture(textureSampler[2], TexCoord);
        } else if (diffTerm > 0.7) {
             diffOut = texture(textureSampler[0], TexCoord);
        } else {
            if (diffTerm > 0.35){
                diffOut = mix(texture(textureSampler[1], TexCoord), texture(textureSampler[0], TexCoord), (diffTerm - 0.35) / 0.35);
            } else if (diffTerm < 0.175){
                diffOut = mix(texture(textureSampler[2], TexCoord), texture(textureSampler[1], TexCoord), (diffTerm) / 0.175);
            } else {
                diffOut = texture(textureSampler[1], TexCoord);
            }    
        }
    }

    return diffOut;
}


/*
    Calls output colour if the edgeVertex flag is not 1, otherwise
    the outputColor is set to black as the fragment is an edge.
*/
void main()
{   
    if (edgeVertex == 1) {
        outputColor = vec4(0.0);
    } else {
        outputColor = calculateOutputColor();
    }
    
}