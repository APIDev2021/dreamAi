export default "\nuniform sampler2D map;\n#ifdef TINT\nuniform float tint;\n#endif\n#ifdef GLITCH\nuniform sampler2D mapDest;\nuniform sampler2D mapDisplace;\nuniform float blend;\nuniform float splitPower;\n\nfloat rand(vec2 co){\n    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);\n}\n\nvec3 colorSplit(sampler2D tex, vec2 uvRaw, float power) {\n    float npower = round(sin((uvRaw.y + power * 12.0 ) * 64.0 / splitPower)) * 0.1 * power;\n    return vec3(\n        texture(tex, uvRaw + vec2(0.04, 0.0) * npower).r,\n        texture(tex, uvRaw + vec2(-0.04, 0.0) * npower).g,\n        texture(tex, uvRaw + vec2(0.0, 0.0) * npower).b\n    );\n}\n\n#endif\n\nvarying vec2 vUv;\n\nvoid main() {\n    #ifdef GLITCH\n\n    // Делаем синусоидальную рампу из 0-1\n    float blendSine = clamp(sin((blend + 0.75) * 3.1415926538 * 2.0) * 0.5 + 0.5, 0.0, 1.0);\n\n    vec3 offset = texture(mapDisplace, vUv).rgb;\n    offset.xy = (offset.xy * 2.0 - 1.0) * 0.02;\n\n    vec3 color = mix(\n        colorSplit(map, vUv, blendSine * splitPower),\n        colorSplit(mapDest, vUv, blendSine * splitPower),\n        offset.z\n    );\n    color = mix(color, vec3(0.0), rand(vUv * 0.1 + vec2(blend * 1.2)) * blendSine * 0.4);\n\n    gl_FragColor = vec4(color, 1.0);\n\n    #else\n\n    gl_FragColor = vec4(texture(map, vUv).rgb, 1.0);\n\n    #endif\n\n    #ifdef TINT\n    gl_FragColor.rgb *= tint;\n    #endif\n}\n";