//
//  Shader.vsh
//  testapp
//
//  Created by Dmytro on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

const char* vertShaderSource = TO_STRING(

attribute vec4 position;
attribute vec4 sourceColor;
attribute mat4 modelview;
uniform mat4 projection;
varying vec4 destinationColor;

void main(void)
{
    destinationColor = sourceColor;
    gl_Position = projection * modelview * position;
}
);
