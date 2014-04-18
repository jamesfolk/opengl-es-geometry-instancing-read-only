//
//  Drawing.h
//  testapp
//
//  Created by Dmytro on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#ifndef DRAWING_H
#define DRAWING_H

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "EAGLView.h"


GLuint program;


void Render(EAGLView* view);

bool LoadShader();
bool CompileShader(GLuint* shader, GLenum type, const char* source);
bool LinkProgram();

double GetCurrentTime();

#endif