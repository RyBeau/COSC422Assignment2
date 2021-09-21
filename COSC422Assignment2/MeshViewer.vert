#version 330

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;


uniform mat4 mvpMatrix;
uniform mat4 norMatrix;
 
out float diffTerm;
out vec3 vertNormal;

void main()
{
	vec4 normalEye = norMatrix * vec4(normal, 0);
	vertNormal = normalize(normalEye.xyz);
	gl_Position = vec4(position, 1);
}