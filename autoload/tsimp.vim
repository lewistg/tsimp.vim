let s:yanked_export = "yanked_export"
let s:yanked_export_abs_path = "yanked_export_abs_path"

function! tsimp#YankcWORDExport() abort
    call tsimp#ClearPutMapping()
    let s:yanked_export = expand("<cword>")
    let s:yanked_export_abs_path = expand("%:p:r")
    let @" = s:yanked_export 
    nnoremap <unique> p :call tsimp#PutImportWithPKey(0)<CR>
    vnoremap <unique> p :call tsimp#PutImportWithPKey(1)<CR>
endfunction

function! tsimp#PutImportWithPKey(is_visual) abort
    call tsimp#ClearPutMapping()
    if @" ==# s:yanked_export
        call tsimp#PutImport(a:is_visual)
    else
        normal! p
    endif
endfunction

function! tsimp#PutImport(is_visual) abort
    echom a:is_visual
    let @" = tsimp#GetImport()
    if (a:is_visual)
        normal! gvp
    else
        put "
    endif
endfunction

function! tsimp#ClearPutMapping() abort
    if maparg("p", "n") !=# ""
        unmap p
    endif
    if maparg("p", "v") !=# ""
        vunmap p
    endif
endfunction

function! tsimp#GetImport() abort
    let l:relative_path = s:GetRelativePath(expand("%:p"), s:yanked_export_abs_path)
    return "import {" . s:yanked_export . "} from '" . relative_path . "';"
endfunction

function! tsimp#GrepImports(import)
    let l:grep_expression = 'import \{(, )?' . a:import . '(,[^\}]*)?\}'
    exe 'grep! "' . l:grep_expression . '"'
endfunction

function! tsimp#UpdateImportPath(file_to_import) abort
    let l:to_file = fnamemodify(a:file_to_import, ":p:r")
    let l:from_file = expand("%:p")
    let l:relative_path = s:GetRelativePath(l:from_file, l:to_file)
    s/\(import .* from \)'\(.*\)';/\=submatch(1) . "'" . l:relative_path . "';"
endfunction

function! tsimp#GetRelativePath(to_abs_path, from_abs_path)
    let to_path_dirs = split(fnamemodify(a:to_abs_path, ":h"), '/')
    let from_path_dirs = split(expand("%:p:h"), '/')

    let to_path_dirs_len = len(to_path_dirs)
    let from_path_dirs_len = len(from_path_dirs)

    let dir_index = 0
    while dir_index < to_path_dirs_len && dir_index < from_path_dirs_len && to_path_dirs[dir_index] ==# from_path_dirs[dir_index]
        let dir_index += 1
    endwhile
    let last_common_ancestor_index = dir_index - 1

    let dir_steps_up_to_common_ancestor = (from_path_dirs_len - 1) - last_common_ancestor_index
    let path_up_to_common_ancestor = "./" . join(repeat(["../"], dir_steps_up_to_common_ancestor), "")

    let to_file_name = fnamemodify(a:to_abs_path, ":t")
    let path_down_to_file = join(add(to_path_dirs[(last_common_ancestor_index + 1):], to_file_name), '/')

    return path_up_to_common_ancestor . path_down_to_file
endfunction

function! s:GetRelativePath(from_abs_path, to_abs_path)
    let to_path_dirs = split(fnamemodify(a:to_abs_path, ":h"), '/')
    let from_path_dirs = split(expand("%:p:h"), '/')

    let to_path_dirs_len = len(to_path_dirs)
    let from_path_dirs_len = len(from_path_dirs)

    let dir_index = 0
    while dir_index < to_path_dirs_len && dir_index < from_path_dirs_len && to_path_dirs[dir_index] ==# from_path_dirs[dir_index]
        let dir_index += 1
    endwhile
    let last_common_ancestor_index = dir_index - 1

    let dir_steps_up_to_common_ancestor = (from_path_dirs_len - 1) - last_common_ancestor_index
    let path_up_to_common_ancestor = "./" . join(repeat(["../"], dir_steps_up_to_common_ancestor), "")

    let to_file_name = fnamemodify(a:to_abs_path, ":t")
    let path_down_to_file = join(add(to_path_dirs[(last_common_ancestor_index + 1):], to_file_name), '/')

    return path_up_to_common_ancestor . path_down_to_file
endfunction

function! tsimp#SetUpFtPlugin() abort
    nnoremap <expr><buffer> <leader>yi tsimp#YankcWORDExport()
    command! -range TsImpPutImport :call tsimp#PutImport() | :call tsimp#ClearPutMapping()
endfunction
