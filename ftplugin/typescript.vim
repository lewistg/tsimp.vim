let s:yankedExport = "yankedExport"
let s:yankedExportAbsPath = "yankedExportAbsPath"

function! s:yankcWORDExport()
    let s:yankedExport = expand("<cWORD>")
    let s:yankedExportAbsPath = expand("%:p:r")
    let @" = s:yankedExport 
    nnoremap p :call <SID>pasteExport()<CR>
endfunction

function! s:pasteExport()
    unmap p

    if @" ==# s:yankedExport
        echom "here"
        let l:relativePath = s:getRelativePath(s:yankedExportAbsPath, expand("%:p"))
        let @" = "import {" . s:yankedExport . "} from '" . relativePath . "';"
        put "
    else
        normal! p
    endif

    let s:yankedExport = ""
endfunction

function! s:getRelativePath(toAbsPath, fromAbsPath)
    let toPathDirs = split(fnamemodify(a:toAbsPath, ":h"), '/')
    let fromPathDirs = split(expand("%:p:h"), '/')

    let toPathDirsLen = len(toPathDirs)
    let fromPathDirsLen = len(fromPathDirs)

    let dirIndex = 0
    while dirIndex < toPathDirsLen && dirIndex < fromPathDirsLen && toPathDirs[dirIndex] ==# fromPathDirs[dirIndex]
        let dirIndex += 1
    endwhile
    let lastCommonAncestorIndex = dirIndex - 1

    let dirStepsUpToCommonAncestor = (fromPathDirsLen - 1) - lastCommonAncestorIndex
    let pathUpToCommonAncestor = "./" . join(repeat(["../"], dirStepsUpToCommonAncestor), "")

    let toFileName = fnamemodify(a:toAbsPath, ":t")
    let pathDownToFile = join(add(toPathDirs[(lastCommonAncestorIndex + 1):], toFileName), '/')

    return pathUpToCommonAncestor . pathDownToFile
endfunction

" Public interface
nnoremap <leader>yi :call <SID>yankcWORDExport()<CR>
