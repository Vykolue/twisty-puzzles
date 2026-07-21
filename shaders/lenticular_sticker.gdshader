shader_type spatial;

varying vec2 world_uv;

void vertex() {
	// Called for every vertex the material is visible on.
	world_uv - (MODEL_MATRIX * vec4(VERTEX.xy, 0.0, 1.0)).xy / 120.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
