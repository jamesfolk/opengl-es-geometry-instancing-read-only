//
//  Drawing.c
//  testapp
//
//  Created by Dmytro on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Drawing.h"
#include <sys/time.h>

#define TO_STRING(A) #A

#define QUADS_COUNT 10000
#define VERTS_PER_QUAD 4

#include "Shaders/Shader.fsh"
#include "Shaders/Shader.vsh"

//http://nukecode.blogspot.com/2011/07/geometry-instancig-for-iphone-wip.html

enum eUniforms
{
	UNIFORM_PROJECTION,
    NUM_UNIFORMS
};

enum eAttributes
{
	ATTRIB_POSITION,
    ATTRIB_COLOR,
	ATTRIB_MODELVIEW,
    NUM_ATTRIBUTES
};

GLint uniforms[NUM_UNIFORMS];
GLint attributes[NUM_ATTRIBUTES];


static const GLfloat identityMatrix[] =
{
	1, 0, 0, 0,
	0, 1, 0, 0,
	0, 0, 1, 0,
	0, 0, 0, 1,
};

static const GLfloat squareVertices[] = 
{
	20.0f, 20.0f,
	45.0f, 20.0f,
	20.0f, 45.0f,
	45.0f, 45.0f,
};


struct vertex
{
	GLfloat x, y;
	GLuint color;
	GLuint padding;
} data[QUADS_COUNT * VERTS_PER_QUAD];

struct _vector4
{
	float v[4];
} __attribute__((aligned(16)));
typedef struct _vector4 vector4;

struct _mat4
{
	float m[16];
} __attribute__((aligned(16)));
typedef struct _mat4 mat4;


GLuint vertexBuffer;
GLuint modelviewBuffer;
GLuint indexBuffer;

GLfloat modelview[QUADS_COUNT * VERTS_PER_QUAD * 16];

void SetupData();

//-------------------------------------------------------------------------------------------
void UpdateModelview()
{
    GLint viewport[4];
    glGetIntegerv( GL_VIEWPORT, viewport );
    
	glBindBuffer(GL_ARRAY_BUFFER, modelviewBuffer);
	GLfloat randVal = 0;
    GLfloat x, y;
    GLuint x_offset = 12;
    GLuint y_offset = 13;
    
	for (int i = 0, offset = 0; i < QUADS_COUNT * VERTS_PER_QUAD; i += 4, offset += 64)
	{
        x = random() % viewport[2];
        y = random() % viewport[3];
        
        for (int j = 0; j < VERTS_PER_QUAD; j++)
        {
            int t = (x_offset + (16 * j));
            modelview[offset + t] = x;
            
            t = (y_offset + (16 * j));
            modelview[offset + t] = y;
        }
        
	}
	
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(modelview), modelview);
	
	const GLuint STRIDE = 64;
	
	glEnableVertexAttribArray(ATTRIB_MODELVIEW + 0);
	glEnableVertexAttribArray(ATTRIB_MODELVIEW + 1);
	glEnableVertexAttribArray(ATTRIB_MODELVIEW + 2);
	glEnableVertexAttribArray(ATTRIB_MODELVIEW + 3);
	glVertexAttribPointer(ATTRIB_MODELVIEW + 0, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)0);
	glVertexAttribPointer(ATTRIB_MODELVIEW + 1, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)16);
	glVertexAttribPointer(ATTRIB_MODELVIEW + 2, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)32);
	glVertexAttribPointer(ATTRIB_MODELVIEW + 3, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)48);
}

//-------------------------------------------------------------------------------------------
void Render(EAGLView* view)
{
	double startTime, endTime, frameTime;
	
	startTime = GetCurrentTime();
    
    float right = 320;
	float left = 0;
	float top = 480;
	float bottom = 0;
	float nearPlane = -1;
	float farPlane = 1;
	
	float a = 2.0f / (right - left);
	float b = 2.0f / (top - bottom);
	float c = -2.0f / (farPlane - nearPlane);
    
	float tx = -(right + left) / (right - left);
	float ty = -(top + bottom) / (top - bottom);
	float tz = (farPlane + nearPlane) / (nearPlane - farPlane);
    
	float projection[16] = 
	{
		a, 0, 0, 0,
		0, b, 0, 0,
		0, 0, c, 0,
		tx, ty, tz, 1
	};
	
	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
	glUseProgram(program);
		
	glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION], 1, 0, projection);
	
	
	UpdateModelview();
	
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
	const GLuint STRIDE = sizeof(data[0]);
	
	glVertexAttribPointer(ATTRIB_POSITION, 2, GL_FLOAT, 0, STRIDE, NULL);
	glEnableVertexAttribArray(ATTRIB_POSITION);
	glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, 1, STRIDE, (GLvoid*)8);
	glEnableVertexAttribArray(ATTRIB_COLOR);
	
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	glDrawElements(GL_TRIANGLES, QUADS_COUNT * 6, GL_UNSIGNED_SHORT, 0);
	
	[view presentFramebuffer];
	
	glFinish();
	
	endTime = GetCurrentTime();
	
	frameTime = endTime - startTime;
	
	static int framesCount = 0;
	
	if (++framesCount == 30)
	{
		NSLog(@"%.5f", 1.0f/frameTime);
		//printf("%.5f\n", 1.0f/frameTime);
		framesCount = 0;
	}
}

//-------------------------------------------------------------------------------------------
void SetupData()
{  
	static const GLuint squareColors[] = 
	{
		0x00ffffff, 0xff00ffff,
		0xffff00ff, 0x00ffffff,
	};
    
	static const GLushort squareIndeces[] = {0, 1, 2, 1, 3, 2};
	GLushort indexes[QUADS_COUNT * 6];
	GLuint indexDelta = 0;
	for (int i = 0; i < QUADS_COUNT * 6; i += 6)
	{
		indexes[i + 0] = squareIndeces[0] + indexDelta;
		indexes[i + 1] = squareIndeces[1] + indexDelta;
		indexes[i + 2] = squareIndeces[2] + indexDelta;
		indexes[i + 3] = squareIndeces[3] + indexDelta;
		indexes[i + 4] = squareIndeces[4] + indexDelta;
		indexes[i + 5] = squareIndeces[5] + indexDelta;
		indexDelta += VERTS_PER_QUAD;
	}
    
	int j = 0;
	const float Y_DELTA = 420.0f / QUADS_COUNT;
	float vertDelta = Y_DELTA;
	for (int i = 0; i < QUADS_COUNT * VERTS_PER_QUAD; ++i)
	{
		data[i].x = squareVertices[j];
		data[i].y = squareVertices[j + 1] + vertDelta;
		data[i].color = squareColors[i % 4];
		
		j += 2;
		if (j == 8)
		{
			j = 0;
			vertDelta += Y_DELTA;
		}
	}
    
	glGenBuffers(1, &vertexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(data), data, GL_STATIC_DRAW);
	
	for (int i = 0; i < QUADS_COUNT * VERTS_PER_QUAD * 16; i += 16)
	{
		memcpy(&modelview[i], identityMatrix, sizeof(identityMatrix));
	}
	
	glGenBuffers(1, &modelviewBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, modelviewBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(modelview), modelview, GL_STREAM_DRAW);
    
	glGenBuffers(1, &indexBuffer);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexes), indexes, GL_STATIC_DRAW);
}

//-------------------------------------------------------------------------------------------
inline double GetCurrentTime()
{
    struct timeval time;
	
    gettimeofday(&time, NULL);
    return (double)time.tv_sec + (0.000001 * (double)time.tv_usec);
}

//-------------------------------------------------------------------------------------------
bool LoadShader()
{
	GLuint vertShader, fragShader;
    
    program = glCreateProgram();
    
    if (!CompileShader(&vertShader, GL_VERTEX_SHADER, vertShaderSource))
    {
        return false;
    }
    
	if (!CompileShader(&fragShader, GL_FRAGMENT_SHADER, fragShaderSource))
    {
        return false;
    }
    
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
	
    glBindAttribLocation(program, ATTRIB_POSITION, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "sourceColor");
	glBindAttribLocation(program, ATTRIB_MODELVIEW, "modelview");
    
    // Link program.
    if (!LinkProgram())
    {	
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return false;
    }
    
    uniforms[UNIFORM_PROJECTION] = glGetUniformLocation(program, "projection");
	
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
	
    SetupData();
    
    return true;
}

//-------------------------------------------------------------------------------------------
bool CompileShader(GLuint* shader, GLenum type, const GLchar* source)
{
	GLint status;
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#ifdef DEBUG
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    //test
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return false;
    }
    
    return true;
}

//-------------------------------------------------------------------------------------------
bool LinkProgram()
{
	GLint status;
    
    glLinkProgram(program);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == 0)
        return false;
    
    return true;
}