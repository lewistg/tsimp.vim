let s:yankedExport = "yankedExport"
let s:yankedExportAbsPath = "yankedExportAbsPath"

function! s:yankExport()
    normal! gvy
    let s:yankedExport = @"
    let s:yankedExportAbsPath = expand("%:p:r")
endfunction

function! s:pasteExport()
	let relativePath = s:getRelativePath(s:yankedExportAbsPath, expand("%:p"))
	let @" = "import {" . s:yankedExport . "} from '" . relativePath . "';"
	normal! p
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

command! -range TsImpYankExport :call s:yankExport()
command! TsImpPasteExport :call s:pasteExport()
