#version 330

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;

uniform mat4 norMatrix;
 
out vec3 vertNormal;

/*
	Vertex shader passes through the vertex normal in eye coordinates
	and the vertex in world coordinates.
*/
void main()
{
	vec4 normalEye = norMatrix * vec4(normal, 0);
	vertNormal = normalize(normalEye.xyz);
	gl_Position = vec4(position, 1);
}