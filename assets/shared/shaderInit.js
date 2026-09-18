async function loadShader(url) {
    const response = await fetch(url);
    return await response.text();
}

function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);

    return shader;
}



const canvas = document.getElementById('backgroundCanvas');
const gl = canvas.getContext('webgl');

const vertexShader = createShader(gl, gl.VERTEX_SHADER, await loadShader('/assets/shared/vertexShader.glsl'));
const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, await loadShader('/assets/shared/fragmentShader.glsl'));

const program = gl.createProgram();
gl.attachShader(program, vertexShader);
gl.attachShader(program, fragmentShader);
gl.linkProgram(program);



const positions = new Float32Array([
    -1, -1,
    1, -1,
    -1,  1,
    1,  1,
]);

const positionBuffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
gl.bufferData(gl.ARRAY_BUFFER, positions, gl.STATIC_DRAW);

const positionLocation = gl.getAttribLocation(program, 'a_position');
gl.enableVertexAttribArray(positionLocation);
gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0);

const timeLocation = gl.getUniformLocation(program, 'iTime');
const resolutionLocation = gl.getUniformLocation(program, 'iResolution');



function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    gl.viewport(0, 0, canvas.width, canvas.height);
}
resizeCanvas();
window.addEventListener('resize', resizeCanvas);



const startTime = Date.now();
function render() {
    const currentTime = (Date.now() - startTime) * 0.001;

    gl.useProgram(program);
    gl.uniform1f(timeLocation, currentTime);
    gl.uniform2f(resolutionLocation, canvas.width, canvas.height);

    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

    requestAnimationFrame(render);
}
render();
