let s:yankedExport = "yankedExport"
let s:yankedExportAbsPath = "yankedExportAbsPath"

function! s:yankSelectedExport()
    normal! gvy
    let s:yankedExport = @"
    let s:yankedExportAbsPath = expand("%:p:r")
endfunction

function! s:yankcWORDExport()
    let s:yankedExport = expand("<cWORD>")
    let s:yankedExportAbsPath = expand("%:p:r")
endfunction

function! s:pasteExport()
	let relativePath = s:getRelativePath(s:yankedExportAbsPath, expand("%:p"))
	let @" = "import {" . s:yankedExport . "} from '" . relativePath . "';"
	pu
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
nnoremap <leader>pi :call <SID>pasteExport()<CR>
