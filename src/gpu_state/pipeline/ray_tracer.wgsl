@group(0) @binding(0) var colorBuffer: texture_storage_2d<rgba8unorm, write>;
@group(1) @binding(0) var<uniform> camera: Camera;
@group(1) @binding(1) var<storage, read> objects: Spheres;

struct Sphere {
    center: vec3<f32>,
	color: vec3<f32>,
    radius: f32,
}

struct Spheres {
	spheres: array<Sphere>,
}

struct Ray {
    direction: vec3<f32>,
    origin: vec3<f32>,
}

struct Camera {
    position: vec3<f32>,
	forwards: vec3<f32>,
	right: vec3<f32>,
	up: vec3<f32>,
}

struct RenderState {
	t: f32,
	color: vec3<f32>,
	hit: bool,
	position: vec3<f32>,
	normal: vec3<f32>,
}

@compute @workgroup_size(1,1,1)
fn main(@builtin(global_invocation_id) id: vec3<u32>) {
    let screenSize: vec2<u32> = textureDimensions(colorBuffer);
    let screenPos: vec2<i32> = vec2<i32>(id.xy);

    let horizontalCoefficient: f32 = (f32(screenPos.x) - f32(screenSize.x) / 2.0) / f32(screenSize.x);
    let verticalCoefficient: f32 = (f32(screenPos.y) - f32(screenSize.y) / 2.0) / f32(screenSize.x);
    let forwards: vec3<f32> = camera.forwards;
    let right: vec3<f32> = camera.right;
    let up: vec3<f32> = camera.up;

    var myRay: Ray;
    myRay.direction = normalize(forwards + horizontalCoefficient * right + verticalCoefficient * up);
    myRay.origin = camera.position;

    var pixelColor: vec3<f32> = rayColor(myRay);

    textureStore(colorBuffer, screenPos, vec4<f32>(pixelColor, 1.0));
}

fn rayColor(ray: Ray) -> vec3<f32> {

    var color: vec3<f32> = vec3(1.0, 1.0, 1.0);
    var result: RenderState;

    var temp_ray: Ray;
    temp_ray.origin = ray.origin;
    temp_ray.direction = ray.direction;

    let bounces: u32 = 4u;
    for(var bounce: u32 = 0u; bounce < bounces; bounce++) {

        result = trace(temp_ray);

        //unpack color
        color = color * result.color;

        //early exit
        if (!result.hit) {
            break;
        }

        //Set up for next trace
        temp_ray.origin = result.position;
        temp_ray.direction = normalize(reflect(temp_ray.direction, result.normal));
    }

    //Rays which reached terminal state and bounced indefinitely
    if (result.hit) {
        color = vec3(0.0, 0.0, 0.0);
    }

    return color;
}

fn trace(ray: Ray) -> RenderState {
    var renderState: RenderState;
	renderState.color = vec3(1.0, 1.0, 1.0);

    var nearestHit: f32 = 9999.0;
    
	for (var i: u32 = 0u; i < arrayLength(&objects.spheres); i++) {
        
        var newRenderState: RenderState = hit(ray, objects.spheres[i], 0.001, nearestHit, renderState);

        if (newRenderState.hit) {
            nearestHit = newRenderState.t;
            renderState = newRenderState;
        }
    }

    return renderState;
}

fn hit(ray: Ray, sphere: Sphere, tMin: f32, tMax: f32, oldRenderState: RenderState) -> RenderState {
    
    let co: vec3<f32> = ray.origin - sphere.center;
    let a: f32 = dot(ray.direction, ray.direction);
    let b: f32 = 2.0 * dot(ray.direction, co);
    let c: f32 = dot(co, co) - sphere.radius * sphere.radius;
    let discriminant: f32 = b * b - 4.0 * a * c;

    var renderState: RenderState;
    renderState.color = oldRenderState.color;

    if (discriminant > 0.0) {

        let t: f32 = (-b - sqrt(discriminant)) / (2.0 * a);

        if (t > tMin && t < tMax) {
			renderState.position = ray.origin + t*ray.direction;
			renderState.normal = normalize(renderState.position - sphere.center);
            renderState.t = t;
            renderState.color = sphere.color;
            renderState.hit = true;
            return renderState;
        }
    }

    renderState.hit = false;
    return renderState;
    
}
