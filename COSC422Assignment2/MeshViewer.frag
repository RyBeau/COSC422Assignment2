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
    Calculates the output colour using the lighting vectors passed through from the Geometry Shader.
    If fog is enabled it also calculates and applies the fog effect.
    Specular reflections are applied only to water.
    Water variation with depth is also calculated here.
*/
vec4 calculateOutputColor(){
    
    if (textureMode){
        vec4 diffOut;
        float diffTerm = max(dot(lgtVec, normalVec), 0.2);

        if (diffTerm < 0){
            diffOut = vec4(0.2, 0.2, 0.2, 1);
        } else if (diffTerm > 0.7) {
            diffOut = vec4(1, 1, 0, 1);
        } else {
            diffOut = vec4(0.5, 0.5, 0, 1);
        }

        return diffOut;
    } else {
        return vec4(0);
    }
}


/*
    Calls the output colour with the given texture for the vertex height. This will vary depending upon the
    set snow and water levels.
*/
void main()
{   
    if (edgeVertex == 1) {
        outputColor = vec4(0.0);
    } else {
        outputColor = calculateOutputColor();
    }
    
}