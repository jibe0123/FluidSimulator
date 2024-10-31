import SwiftUI
import MetalKit

struct ContentView: View {
    var body: some View {
        MetalFluidView()
            .ignoresSafeArea()
    }
}

#if os(macOS)
struct MetalFluidView: NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.preferredFramesPerSecond = 60
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.framebufferOnly = false // Permet d'utiliser la texture pour des opérations de calcul
        mtkView.delegate = context.coordinator
        return mtkView
    }

    func updateNSView(_ nsView: MTKView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
#else
struct MetalFluidView: UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.preferredFramesPerSecond = 60
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.framebufferOnly = false // Permet d'utiliser la texture pour des opérations de calcul
        mtkView.delegate = context.coordinator
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
#endif

class Coordinator: NSObject, MTKViewDelegate {
    var commandQueue: MTLCommandQueue?
    var pipelineState: MTLComputePipelineState?
    var time: Float = 0.0

    override init() {
        let device = MTLCreateSystemDefaultDevice()
        commandQueue = device?.makeCommandQueue()

        // Load the shader
        let library = device?.makeDefaultLibrary()
        let function = library?.makeFunction(name: "fluidShader")
        pipelineState = try? device?.makeComputePipelineState(function: function!)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let commandBuffer = commandQueue?.makeCommandBuffer(),
              let pipelineState = pipelineState else { return }

        time += 0.01

        let encoder = commandBuffer.makeComputeCommandEncoder()
        var time = self.time

        encoder?.setComputePipelineState(pipelineState)
        encoder?.setBytes(&time, length: MemoryLayout<Float>.size, index: 0)
        encoder?.setTexture(drawable.texture, index: 0)

        let width = pipelineState.threadExecutionWidth
        let height = pipelineState.maxTotalThreadsPerThreadgroup / width
        let threadsPerGroup = MTLSize(width: width, height: height, depth: 1)
        let threadsPerGrid = MTLSize(width: drawable.texture.width,
                                     height: drawable.texture.height,
                                     depth: 1)
        encoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        encoder?.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
