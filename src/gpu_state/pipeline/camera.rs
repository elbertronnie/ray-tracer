use std::mem::size_of;
use bytemuck::{Pod, Zeroable};
use wgpu::{
    VertexBufferLayout, VertexStepMode, BufferAddress, VertexAttribute, 
    VertexFormat
};


#[repr(C)]
#[derive(Copy, Clone, Debug, Pod, Zeroable)]
pub struct Camera {
    pub color: [f32; 4],
}


/*
pub struct Camera {
    position: [f32; 3],
    _position_padding: f32,
    forwards: [f32; 3],
    _forwards_padding: f32,
    right: [f32; 3],
    _right_padding: f32,
    up: [f32; 3],
    _up_padding: f32,
}

impl Camera {
    pub const fn new(position: [f32; 3], forwards: [f32; 3], right: [f32; 3], up: [f32; 3]) -> Camera {
        Camera {
            position,
            forwards,
            right,
            up,

            _position_padding: 0.0,
            _forwards_padding: 0.0,
            _right_padding: 0.0,
            _up_padding: 0.0,
        }
    }
}

impl Default for Camera {
    fn default() -> Camera {
        Camera::new(
            [0.0, 0.0, 0.0],
            [1.0, 0.0, 0.0],
            [0.0, -1.0, 0.0],
            [0.0, 0.0, 1.0],
        )
    }
}
*/
