#define gridSizeMultiplier 5.0
#define mutationSpeedMultiplier 0.2
#define brightnessMultiplier 0.1
#define viewportVelocityX 0.1
#define viewportVelocityY 0.04
#define randomFactor 0.02
#define pixelSize 1.0



precision mediump float;

uniform float iTime;
uniform vec2 iResolution;
float random(vec2 parameter) {
    float value = fract(sin(dot(parameter.xy, vec2(12.9898, 78.233))) * 43758.5453123); // [0.0, 1.0]
    return value * 2.0 - 1.0; // [-1.0, 1.0]
}

vec2 getHash(vec2 position) {
    float vectorAngle = dot(position, vec2(127.1, 311.7));
    float randomOffset = fract(sin(vectorAngle) * 43758.5453123) * 6.283185;
    float timeFactor = iTime * mutationSpeedMultiplier;

    float direction = (fract(sin(dot(position, vec2(269.5, 183.3))) * 43758.5453123) > 0.5) ? 1.0 : -1.0;
    vectorAngle = randomOffset + timeFactor * 1.5 * direction;

    return vec2(cos(vectorAngle), sin(vectorAngle));
}

float getBrightness(vec2 absolutePosition) {
    vec2 vertexIndex = floor(absolutePosition);
    vec2 relativePosition = fract(absolutePosition);

    float leftBottomCorner = dot(getHash(vertexIndex + vec2(0.0, 0.0)), relativePosition - vec2(0.0, 0.0));
    float rightBottomCorner = dot(getHash(vertexIndex + vec2(1.0, 0.0)), relativePosition - vec2(1.0, 0.0));
    float leftTopCorner = dot(getHash(vertexIndex + vec2(0.0, 1.0)), relativePosition - vec2(0.0, 1.0));
    float rightTopCorner = dot(getHash(vertexIndex + vec2(1.0, 1.0)), relativePosition - vec2(1.0, 1.0));

    vec2 lerpPercent = relativePosition * relativePosition * relativePosition * (relativePosition * (relativePosition * 6.0 - 15.0) + 10.0);
    float brightness = mix(mix(leftBottomCorner, rightBottomCorner, lerpPercent.x), mix(leftTopCorner, rightTopCorner, lerpPercent.x), lerpPercent.y);
    brightness = brightness * 0.707 + 0.5; // [0.0; 1.0]

    float grainedBrightness = brightness + random(absolutePosition) * randomFactor;
    float steppedBrightness = floor(grainedBrightness * 10.0) / 10.0;

    return steppedBrightness * brightnessMultiplier;
}

void mainImage(out vec4 fragColor, in vec2 position) {
    vec2 pixelPos = floor(position / pixelSize) * pixelSize;
    vec2 uv = (pixelPos / iResolution.y) * gridSizeMultiplier;
    uv += vec2(iTime * viewportVelocityX, iTime * viewportVelocityY);

    float pixelBrightness = getBrightness(uv);
    fragColor = vec4(vec3(pixelBrightness / 2.0, pixelBrightness * 2.0, pixelBrightness * 2.0), 1.0);
}



void main() {
    vec2 position = gl_FragCoord.xy;
    vec4 outputColor;

    mainImage(outputColor, position);
    gl_FragColor = outputColor;
}