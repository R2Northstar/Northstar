.data
extern PA : qword
.code
RunASM proc
jmp qword ptr [PA]
RunASM endp
end
