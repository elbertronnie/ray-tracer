use bytemuck::{Pod, Zeroable};
use rand::random;

#[repr(C)]
#[derive(Copy, Clone, Debug, Pod, Zeroable)]
pub struct SphereStorage {
    center: [f32; 3],
    _center_padding: f32,
    color: [f32; 3],
    radius: f32,
}

impl SphereStorage {
    pub fn new(center: [f32; 3], color: [f32; 3], radius: f32) -> SphereStorage {
        SphereStorage {
            center,
            color,
            radius,

            _center_padding: 0.0,
        }
    }

    pub fn new_random() -> SphereStorage {
        let center = [10.0 + 10.0*random::<f32>(), 10.0*random::<f32>(), 10.0*random::<f32>()];
        let color = [random::<f32>(), random::<f32>(), random::<f32>()];
        let radius = 5.0 * random::<f32>();
        SphereStorage::new(center, color, radius)
    }
}
