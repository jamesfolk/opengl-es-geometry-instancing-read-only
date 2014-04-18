//
//  Shader.fsh
//  testapp
//
//  Created by Dmytro on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

const char* fragShaderSource = TO_STRING(
											 
varying lowp vec4 destinationColor;
											 
void main(void)
{
    gl_FragColor = destinationColor;
}
);