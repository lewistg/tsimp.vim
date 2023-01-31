""
" Suggested autogroup:
" ```
" augroup tsimp
"     autocmd!
"     autocmd FileType typescript nmap <buffer> <leader>yi <Plug>Plug>TsImpYankcWORDExport
"     autocmd FileType javascript nmap <buffer> <leader>yi <Plug>Plug>TsImpYankcWORDExport
" augroup END
" ```
nnoremap <expr> <Plug>TsImpYankcWORDExport tsimp#YankcWORDExport()

command! -range TsImpPutImport :call tsimp#PutImport() | :call tsimp#ClearPutMapping()
