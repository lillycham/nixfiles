(() => {
  // node_modules/.pnpm/colourmush@0.1.1/node_modules/colourmush/dist/chunk-YUNXT7QB.js
  var toLinear = (c) => {
    const x = c / 255;
    return x <= 0.04045 ? x / 12.92 : ((x + 0.055) / 1.055) ** 2.4;
  };
  var fromLinear = (x) => {
    const c = x <= 31308e-7 ? x * 12.92 : 1.055 * x ** (1 / 2.4) - 0.055;
    return c * 255;
  };
  var clamp255 = (x) => Math.min(255, Math.max(0, x));
  function rgbToOklab([r, g, b]) {
    const lr = toLinear(r);
    const lg = toLinear(g);
    const lb = toLinear(b);
    const l = Math.cbrt(0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb);
    const m = Math.cbrt(0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb);
    const s = Math.cbrt(0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb);
    return [
      0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s,
      1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s,
      0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s
    ];
  }
  function oklabToRgb([L, a, b]) {
    const l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3;
    const m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3;
    const s = (L - 0.0894841775 * a - 1.291485548 * b) ** 3;
    return [
      clamp255(fromLinear(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s)),
      clamp255(fromLinear(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s)),
      clamp255(fromLinear(-0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s))
    ];
  }
  var chroma = ([, a, b]) => Math.hypot(a, b);
  var labDistance = (p, q) => Math.hypot(p[0] - q[0], p[1] - q[1], p[2] - q[2]);
  function rgbToHex([r, g, b]) {
    const h = (c) => Math.round(clamp255(c)).toString(16).padStart(2, "0");
    return `#${h(r)}${h(g)}${h(b)}`;
  }
  function mulberry32(seed) {
    let a = seed >>> 0;
    return () => {
      a = a + 1831565813 >>> 0;
      let t = a;
      t = Math.imul(t ^ t >>> 15, t | 1);
      t ^= t + Math.imul(t ^ t >>> 7, t | 61);
      return ((t ^ t >>> 14) >>> 0) / 4294967296;
    };
  }
  var dist2 = (p, i, c, j) => {
    const dx = p[i] - c[j];
    const dy = p[i + 1] - c[j + 1];
    const dz = p[i + 2] - c[j + 2];
    return dx * dx + dy * dy + dz * dz;
  };
  function kmeans(points, k, seed = 1, maxIter = 20) {
    const n = Math.floor(points.length / 3);
    k = Math.min(k, n);
    if (k <= 0) return { centroids: new Float32Array(0), counts: new Uint32Array(0) };
    const rand = mulberry32(seed);
    const centroids = new Float32Array(k * 3);
    const nearest = new Float32Array(n).fill(Infinity);
    for (let c = 0; c < k; c++) {
      let pick = Math.floor(rand() * n);
      if (c > 0) {
        let total = 0;
        for (let i = 0; i < n; i++) total += nearest[i];
        if (total > 0) {
          let r = rand() * total;
          for (let i = 0; i < n; i++) {
            r -= nearest[i];
            if (r <= 0) {
              pick = i;
              break;
            }
          }
        }
      }
      centroids.set(points.subarray(pick * 3, pick * 3 + 3), c * 3);
      for (let i = 0; i < n; i++) {
        nearest[i] = Math.min(nearest[i], dist2(points, i * 3, centroids, c * 3));
      }
    }
    const assign = new Uint32Array(n);
    const counts = new Uint32Array(k);
    const sums = new Float64Array(k * 3);
    for (let iter = 0; iter < maxIter; iter++) {
      let changed = iter === 0;
      counts.fill(0);
      sums.fill(0);
      for (let i = 0; i < n; i++) {
        let best = 0;
        let bestD = Infinity;
        for (let c = 0; c < k; c++) {
          const d = dist2(points, i * 3, centroids, c * 3);
          if (d < bestD) {
            bestD = d;
            best = c;
          }
        }
        if (assign[i] !== best) changed = true;
        assign[i] = best;
        counts[best]++;
        sums[best * 3] += points[i * 3];
        sums[best * 3 + 1] += points[i * 3 + 1];
        sums[best * 3 + 2] += points[i * 3 + 2];
      }
      if (!changed) break;
      for (let c = 0; c < k; c++) {
        const count = counts[c];
        if (count === 0) continue;
        centroids[c * 3] = sums[c * 3] / count;
        centroids[c * 3 + 1] = sums[c * 3 + 1] / count;
        centroids[c * 3 + 2] = sums[c * 3 + 2] / count;
      }
    }
    return { centroids, counts };
  }
  function createSurface(w, h) {
    if (typeof OffscreenCanvas !== "undefined") return new OffscreenCanvas(w, h);
    const canvas = document.createElement("canvas");
    canvas.width = w;
    canvas.height = h;
    return canvas;
  }
  async function decode(src) {
    if (typeof src === "string") {
      const img = new Image();
      img.crossOrigin = "anonymous";
      img.decoding = "async";
      img.src = src;
      await img.decode();
      return img;
    }
    if (src instanceof Blob) return createImageBitmap(src);
    if (src instanceof HTMLImageElement && !src.complete) await src.decode();
    return src;
  }
  var sizeOf = (s) => {
    if (s instanceof HTMLImageElement) return [s.naturalWidth, s.naturalHeight];
    if (s instanceof HTMLVideoElement) return [s.videoWidth, s.videoHeight];
    const { width, height } = s;
    return [width, height];
  };
  async function toPixelData(src, sampleSize) {
    const image = await decode(src);
    const [w, h] = sizeOf(image);
    if (!w || !h) throw new Error("colourmush: image has no pixels");
    const scale = Math.min(1, sampleSize / Math.max(w, h));
    const tw = Math.max(1, Math.round(w * scale));
    const th = Math.max(1, Math.round(h * scale));
    const surface = createSurface(tw, th);
    const ctx = surface.getContext("2d", { willReadFrequently: true });
    if (!ctx) throw new Error("colourmush: 2D canvas is unavailable");
    ctx.drawImage(image, 0, 0, tw, th);
    return ctx.getImageData(0, 0, tw, th);
  }
  var MIN_ALPHA = 125;
  var OVERCLUSTER = 3;
  var MIN_SEPARATION = 0.06;
  var FALLBACK = [128, 128, 128];
  var score = (population, lab) => population * (0.35 + Math.min(chroma(lab), 0.2) / 0.2);
  function paletteFromPixels(img, opts = {}) {
    const { count = 5, seed = 1 } = opts;
    const { data } = img;
    const points = new Float32Array(data.length / 4 * 3);
    let n = 0;
    for (let i = 0; i < data.length; i += 4) {
      if (data[i + 3] < MIN_ALPHA) continue;
      const [L, a, b] = rgbToOklab([data[i], data[i + 1], data[i + 2]]);
      points[n * 3] = L;
      points[n * 3 + 1] = a;
      points[n * 3 + 2] = b;
      n++;
    }
    const colours = [];
    if (n > 0) {
      const { centroids, counts } = kmeans(points.subarray(0, n * 3), count * OVERCLUSTER, seed);
      const clusters = Array.from(counts, (population, c) => {
        const lab = [centroids[c * 3], centroids[c * 3 + 1], centroids[c * 3 + 2]];
        return { lab, population, score: score(population, lab) };
      }).filter((c) => c.population > 0).sort((p, q) => q.score - p.score);
      const picked = [];
      for (const c of clusters) {
        if (picked.length === count) break;
        if (picked.every((p) => labDistance(p.lab, c.lab) >= MIN_SEPARATION)) picked.push(c);
      }
      for (const c of clusters) {
        if (picked.length === count) break;
        if (!picked.includes(c)) picked.push(c);
      }
      for (const c of picked) colours.push(oklabToRgb(c.lab));
    }
    if (colours.length === 0) colours.push(FALLBACK);
    for (let i = 0; colours.length < count; i++) colours.push(colours[i % colours.length]);
    return { colours, hex: colours.map(rgbToHex) };
  }
  async function extractPalette(src, opts = {}) {
    return paletteFromPixels(await toPixelData(src, opts.sampleSize ?? 64), opts);
  }
  function toRGB(colour) {
    if (typeof colour !== "string") return colour;
    const m = /^#?([0-9a-f]{3}|[0-9a-f]{6})$/i.exec(colour.trim());
    if (!m) throw new Error(`colourmush: cannot parse colour "${colour}"`);
    let hex = m[1];
    if (hex.length === 3) hex = [...hex].map((c) => c + c).join("");
    const n = parseInt(hex, 16);
    return [n >> 16 & 255, n >> 8 & 255, n & 255];
  }
  function createCanvasPainter(canvas) {
    const ctx = canvas.getContext("2d");
    if (!ctx) throw new Error("colourmush: no rendering context available");
    return {
      draw({ time: t, lab, width, height, intensity }) {
        const rgb = Array.from(
          { length: 5 },
          (_, i) => oklabToRgb([lab[i * 3], lab[i * 3 + 1] * 1.12, lab[i * 3 + 2] * 1.12])
        );
        const css = (i, a) => `rgba(${rgb[i].map(Math.round).join(",")},${a})`;
        ctx.globalCompositeOperation = "source-over";
        ctx.fillStyle = css(0, 1);
        ctx.fillRect(0, 0, width, height);
        const reach = Math.max(width, height) * (0.55 + 0.15 * intensity);
        for (let i = 1; i < 5; i++) {
          const x = width * (0.5 + 0.42 * Math.sin(t * 0.13 * (1 + i * 0.31) + i * 2.1));
          const y = height * (0.5 + 0.4 * Math.cos(t * 0.17 * (1 + i * 0.23) + i * 1.3));
          const g = ctx.createRadialGradient(x, y, 0, x, y, reach);
          g.addColorStop(0, css(i, 0.9));
          g.addColorStop(1, css(i, 0));
          ctx.fillStyle = g;
          ctx.fillRect(0, 0, width, height);
        }
      },
      destroy() {
      }
    };
  }
  var VERTEX = (
    /* glsl */
    `
attribute vec2 aPos;
void main() { gl_Position = vec4(aPos, 0.0, 1.0); }
`
  );
  var FRAGMENT = (
    /* glsl */
    `
precision highp float;

uniform vec2 uRes;
uniform float uTime;
uniform float uIntensity;
uniform float uGrain;
uniform vec3 uLab[5];

// 2D simplex noise, Ashima Arts / Ian McEwan (MIT).
vec3 permute(vec3 x) { return mod(((x * 34.0) + 1.0) * x, 289.0); }
float snoise(vec2 v) {
  const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
  vec2 i = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);
  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
  vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
  m = m * m;
  m = m * m;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
  vec3 g;
  g.x = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

vec3 oklabToSrgb(vec3 c) {
  float l = c.x + 0.3963377774 * c.y + 0.2158037573 * c.z;
  float m = c.x - 0.1055613458 * c.y - 0.0638541728 * c.z;
  float s = c.x - 0.0894841775 * c.y - 1.2914855480 * c.z;
  l = l * l * l; m = m * m * m; s = s * s * s;
  vec3 lin = vec3(
     4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s);
  lin = clamp(lin, 0.0, 1.0);
  return mix(lin * 12.92, 1.055 * pow(lin, vec3(1.0 / 2.4)) - 0.055, step(0.0031308, lin));
}

void main() {
  float aspect = uRes.x / uRes.y;
  vec2 p = (gl_FragCoord.xy / uRes - 0.5) * vec2(aspect, 1.0);
  float t = uTime;

  // Two layers of warp, the second fed by the first, for the liquid look.
  vec2 q = vec2(snoise(p * 1.2 + vec2(0.0, t * 0.15)),
                snoise(p * 1.2 + vec2(5.2, -t * 0.12)));
  vec2 r = vec2(snoise(p * 1.6 + 2.0 * q + vec2(1.7, 9.2) + t * 0.10),
                snoise(p * 1.6 + 2.0 * q + vec2(8.3, 2.8) - t * 0.08));
  vec2 w = p + uIntensity * (0.30 * q + 0.22 * r);

  vec3 acc = vec3(0.0);
  float total = 0.0;
  for (int i = 0; i < 5; i++) {
    float f = float(i);
    vec2 anchor = vec2(
      aspect * 0.42 * sin(t * 0.13 * (1.0 + f * 0.31) + f * 2.1),
      0.40 * cos(t * 0.17 * (1.0 + f * 0.23) + f * 1.3));
    vec2 d = w - anchor;
    float weight = 1.0 / (dot(d, d) + 0.06);
    weight *= weight * (1.35 - 0.12 * f); // the dominant colour gets a bit more room
    acc += uLab[i] * weight;
    total += weight;
  }

  vec3 lab = acc / total;
  lab.yz *= 1.12; // slightly richer than the source art
  vec3 rgb = oklabToSrgb(lab);

  // Grain doubles as dithering, which hides banding in the slow gradients.
  rgb += (hash(gl_FragCoord.xy + fract(t)) - 0.5) * uGrain;
  gl_FragColor = vec4(clamp(rgb, 0.0, 1.0), 1.0);
}
`
  );
  function compile(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      const log = gl.getShaderInfoLog(shader);
      gl.deleteShader(shader);
      throw new Error(`colourmush: shader compile failed: ${log}`);
    }
    return shader;
  }
  function createWebGLPainter(canvas) {
    const gl = canvas.getContext("webgl", { antialias: false, alpha: false, powerPreference: "low-power" });
    if (!gl) throw new Error("colourmush: WebGL is unavailable");
    const program = gl.createProgram();
    const vs = compile(gl, gl.VERTEX_SHADER, VERTEX);
    const fs = compile(gl, gl.FRAGMENT_SHADER, FRAGMENT);
    gl.attachShader(program, vs);
    gl.attachShader(program, fs);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      throw new Error(`colourmush: program link failed: ${gl.getProgramInfoLog(program)}`);
    }
    gl.useProgram(program);
    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW);
    const aPos = gl.getAttribLocation(program, "aPos");
    gl.enableVertexAttribArray(aPos);
    gl.vertexAttribPointer(aPos, 2, gl.FLOAT, false, 0, 0);
    const uRes = gl.getUniformLocation(program, "uRes");
    const uTime = gl.getUniformLocation(program, "uTime");
    const uIntensity = gl.getUniformLocation(program, "uIntensity");
    const uGrain = gl.getUniformLocation(program, "uGrain");
    const uLab = gl.getUniformLocation(program, "uLab");
    return {
      draw({ time, lab, width, height, intensity, grain }) {
        if (gl.isContextLost()) return;
        gl.viewport(0, 0, width, height);
        gl.uniform2f(uRes, width, height);
        gl.uniform1f(uTime, time);
        gl.uniform1f(uIntensity, intensity);
        gl.uniform1f(uGrain, grain);
        gl.uniform3fv(uLab, lab);
        gl.drawArrays(gl.TRIANGLES, 0, 3);
      },
      destroy() {
        gl.deleteBuffer(buffer);
        gl.deleteProgram(program);
        gl.deleteShader(vs);
        gl.deleteShader(fs);
        gl.getExtension("WEBGL_lose_context")?.loseContext();
      }
    };
  }
  var DEFAULT_COLOURS = ["#5b6ee1", "#e1578a", "#f2a65a", "#3fb8af", "#7a4fd0"];
  var STILL_TIME = 12;
  var smoothstep = (x) => x * x * (3 - 2 * x);
  function toLabArray(colours) {
    if (colours.length === 0) throw new Error("colourmush: at least one colour is required");
    const out = new Float32Array(15);
    for (let i = 0; i < 5; i++) {
      out.set(rgbToOklab(toRGB(colours[i % colours.length])), i * 3);
    }
    return out;
  }
  var ColourMush = class {
    canvas;
    painter;
    container;
    speed;
    intensity;
    grain;
    renderScale;
    respectReducedMotion;
    lab;
    from;
    target;
    fade = { start: 0, duration: 0 };
    time = STILL_TIME;
    lastFrame = 0;
    raf = 0;
    paused = false;
    visible = true;
    inView = true;
    reducedMotion = false;
    destroyed = false;
    resizeObserver;
    intersectionObserver;
    motionQuery;
    constructor(container, opts = {}) {
      this.container = container;
      this.speed = opts.speed ?? 1;
      this.intensity = opts.intensity ?? 1;
      this.grain = opts.grain ?? 0.04;
      this.renderScale = opts.renderScale ?? 0.5;
      this.respectReducedMotion = opts.respectReducedMotion ?? true;
      this.lab = toLabArray(opts.colours ?? DEFAULT_COLOURS);
      this.from = this.lab.slice();
      this.target = this.lab.slice();
      this.mountCanvas();
      this.motionQuery = window.matchMedia("(prefers-reduced-motion: reduce)");
      this.reducedMotion = this.respectReducedMotion && this.motionQuery.matches;
      this.motionQuery.addEventListener("change", this.onMotionChange);
      document.addEventListener("visibilitychange", this.onVisibility);
      this.visible = !document.hidden;
      this.resizeObserver = new ResizeObserver(() => {
        this.resize();
        this.render(this.reducedMotion ? STILL_TIME : this.time);
      });
      this.resizeObserver.observe(container);
      this.intersectionObserver = new IntersectionObserver((entries) => {
        this.inView = entries.some((e) => e.isIntersecting);
        this.update();
      });
      this.intersectionObserver.observe(container);
      this.resize();
      this.update();
    }
    /** Cross-fades to a new set of colours, e.g. when the track changes. */
    setPalette(colours, { transitionMs = 1200 } = {}) {
      if (this.destroyed) return;
      this.from = this.lab.slice();
      this.target = toLabArray(colours);
      if (transitionMs <= 0 || !this.animating) {
        this.lab = this.target.slice();
        this.fade.duration = 0;
        this.drawStill();
      } else {
        this.fade = { start: performance.now(), duration: transitionMs };
      }
    }
    setOptions(opts) {
      this.speed = opts.speed ?? this.speed;
      this.intensity = opts.intensity ?? this.intensity;
      this.grain = opts.grain ?? this.grain;
      this.drawStill();
    }
    pause() {
      this.paused = true;
      this.update();
    }
    resume() {
      this.paused = false;
      this.update();
    }
    destroy() {
      if (this.destroyed) return;
      this.destroyed = true;
      cancelAnimationFrame(this.raf);
      this.resizeObserver.disconnect();
      this.intersectionObserver.disconnect();
      this.motionQuery.removeEventListener("change", this.onMotionChange);
      document.removeEventListener("visibilitychange", this.onVisibility);
      this.painter.destroy();
      this.canvas.remove();
    }
    get animating() {
      return !this.paused && this.visible && this.inView && !this.reducedMotion && !this.destroyed;
    }
    mountCanvas() {
      this.canvas?.remove();
      const canvas = document.createElement("canvas");
      canvas.style.cssText = "position:absolute;inset:0;width:100%;height:100%;display:block;";
      canvas.setAttribute("aria-hidden", "true");
      this.container.prepend(canvas);
      this.canvas = canvas;
      try {
        this.painter = createWebGLPainter(canvas);
        canvas.addEventListener("webglcontextlost", this.onContextLost);
        canvas.addEventListener("webglcontextrestored", this.onContextRestored);
      } catch {
        const fresh = canvas.cloneNode(false);
        canvas.replaceWith(fresh);
        this.canvas = fresh;
        this.painter = createCanvasPainter(fresh);
      }
    }
    onContextLost = (e) => {
      e.preventDefault();
      cancelAnimationFrame(this.raf);
      this.raf = 0;
    };
    onContextRestored = () => {
      this.painter.destroy();
      this.mountCanvas();
      this.resize();
      this.update();
    };
    onVisibility = () => {
      this.visible = !document.hidden;
      this.update();
    };
    onMotionChange = () => {
      this.reducedMotion = this.respectReducedMotion && this.motionQuery.matches;
      if (this.reducedMotion) this.lab = this.target.slice();
      this.update();
    };
    resize() {
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      const w = Math.max(1, Math.round(this.container.clientWidth * dpr * this.renderScale));
      const h = Math.max(1, Math.round(this.container.clientHeight * dpr * this.renderScale));
      if (this.canvas.width !== w || this.canvas.height !== h) {
        this.canvas.width = w;
        this.canvas.height = h;
      }
    }
    /** Starts or stops the loop to match the current state, drawing one frame either way. */
    update() {
      cancelAnimationFrame(this.raf);
      this.raf = 0;
      if (this.animating) {
        this.lastFrame = performance.now();
        this.raf = requestAnimationFrame(this.tick);
      } else {
        this.drawStill();
      }
    }
    drawStill() {
      if (this.animating) return;
      this.render(this.reducedMotion ? STILL_TIME : this.time);
    }
    tick = (now) => {
      const dt = Math.min((now - this.lastFrame) / 1e3, 0.1);
      this.lastFrame = now;
      this.time += dt * this.speed;
      if (this.fade.duration > 0) {
        const k = Math.min((now - this.fade.start) / this.fade.duration, 1);
        const e = smoothstep(k);
        for (let i = 0; i < 15; i++) {
          this.lab[i] = this.from[i] + (this.target[i] - this.from[i]) * e;
        }
        if (k >= 1) this.fade.duration = 0;
      }
      this.render(this.time);
      this.raf = requestAnimationFrame(this.tick);
    };
    render(time) {
      this.painter.draw({
        time,
        lab: this.lab,
        width: this.canvas.width,
        height: this.canvas.height,
        intensity: this.intensity,
        grain: this.grain
      });
    }
  };

  // src/index.js
  (() => {
    const id = "colourmush-lyrics-extension";
    if (window[id]) window[id]();
    let disposed = false;
    let player = null;
    let retry = 0;
    let artwork = "";
    let palette = null;
    let request = 0;
    const mounted = /* @__PURE__ */ new Map();
    function unmount(host) {
      const entry = mounted.get(host);
      if (!entry) return;
      entry.mush.destroy();
      entry.layer.remove();
      host.classList.remove("colourmush-host");
      mounted.delete(host);
    }
    function imageUrl() {
      const item = player?.data?.item;
      const url = item?.metadata?.image_xlarge_url || item?.metadata?.image_url || item?.images?.[0]?.url || "";
      return url.replace(/^spotify:image:([a-f0-9]+)$/i, "https://i.scdn.co/image/$1");
    }
    function targets() {
      const lyrics = document.querySelector(".lyrics-lyrics-container .lyrics-lyrics-background");
      const sidebar = document.querySelector(".Root__right-sidebar .main-nowPlayingView-container [data-npv-root]");
      const cinema = document.querySelector('.Root__cinema-view [style*="--cinema-mode-bg-color-from"]');
      const gradient = cinema && [...cinema.children].find((child) => getComputedStyle(child).position === "absolute" && getComputedStyle(child).backgroundImage.includes("gradient"));
      return [[lyrics, "lyrics"], [gradient ? null : sidebar, "sidebar"], [gradient, "cinema"]].filter(([host]) => host && host.isConnected && host.getBoundingClientRect().width > 0);
    }
    function reconcile() {
      if (disposed) return;
      const wanted = new Map(targets());
      for (const host of mounted.keys()) if (!wanted.has(host)) unmount(host);
      if (!palette) return;
      for (const [host, kind] of wanted) {
        if (mounted.has(host)) continue;
        const layer = document.createElement("div");
        layer.className = `colourmush-layer colourmush-${kind}`;
        host.classList.add("colourmush-host");
        host.prepend(layer);
        try {
          const mush = new ColourMush(layer, { colours: palette, speed: 0.5, intensity: 0.01 });
          mounted.set(host, { layer, mush });
        } catch (error) {
          layer.remove();
          host.classList.remove("colourmush-host");
          console.warn("[colourmush] Could not create background:", error);
        }
      }
    }
    async function updateArtwork() {
      const url = imageUrl();
      if (url === artwork) return;
      artwork = url;
      palette = null;
      const current = ++request;
      if (!url) {
        for (const host of mounted.keys()) unmount(host);
        return;
      }
      try {
        const result = await extractPalette(url);
        if (disposed || current !== request) return;
        palette = result.colours;
        for (const { mush } of mounted.values()) mush.setPalette(palette);
        reconcile();
      } catch (error) {
        if (current !== request) return;
        for (const host of mounted.keys()) unmount(host);
        console.warn("[colourmush] Could not read the current artwork:", error);
      }
    }
    const style = document.createElement("style");
    style.textContent = `
    .lyrics-lyrics-background.colourmush-host { position: relative; }
    .colourmush-layer { pointer-events: none; }
    .colourmush-lyrics { position: sticky; top: 0; width: 100%; height: 100vh; }
    .colourmush-lyrics::after, .colourmush-sidebar::after, .colourmush-cinema::after { content: ''; position: absolute; inset: 0; background: rgba(0, 0, 0, 0.35); pointer-events: none; }
    [data-npv-root].colourmush-host { isolation: isolate; }
    .colourmush-sidebar { position: absolute; inset: 0; z-index: -1; }
    .colourmush-cinema { position: absolute; inset: 0; }
  `;
    document.head.append(style);
    const observer = new MutationObserver(reconcile);
    function start() {
      if (disposed) return;
      player = window.Spicetify?.Player;
      if (!player?.addEventListener || !player?.data?.item) {
        retry = setTimeout(start, 500);
        return;
      }
      observer.observe(document, { childList: true, subtree: true });
      player.addEventListener("songchange", updateArtwork);
      updateArtwork();
    }
    window[id] = () => {
      disposed = true;
      request++;
      clearTimeout(retry);
      observer.disconnect();
      player?.removeEventListener("songchange", updateArtwork);
      for (const host of mounted.keys()) unmount(host);
      style.remove();
      delete window[id];
    };
    start();
  })();
})();
