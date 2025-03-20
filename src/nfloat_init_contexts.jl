for P = 1:66
    for F = 0:7
        @eval const $(Symbol(:_nfloat_ctx_struct_, P, :_, F)) = nfloat_ctx_struct{$P,$F}()
    end
end
