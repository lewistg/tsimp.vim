let s:yankedExport = "yankedExport"
let s:yankedExportAbsPath = "yankedExportAbsPath"

function! s:getRelativePath(toAbsPath, fromAbsPath)
    let toPathParts = split(a:toAbsPath, '/')
    let fromPathParts = split(expand("%:p"), '/')

    let toPathPartsLen = len(toPathParts) - 1
    let fromPathPartsLen = len(fromPathParts) - 1

    let dirIndex = 0
    while toPathParts[dirIndex] ==# fromPathParts[dirIndex] && dirIndex < toPathPartsLen && dirIndex < fromPathPartsLen
        let dirIndex += 1
    endwhile

    let relativeFilepath = join(toPathParts[dirIndex:], '/')
    while dirIndex < fromPathPartsLen
        let relativeFilepath = '../' . relativeFilepath
        let dirIndex += 1
    endwhile
    let relativeFilepath = './' . relativeFilepath

    return relativeFilepath
endfunction

function! s:yankExport()
    normal! gvy
    let s:yankedExport = @"
    let s:yankedExportAbsPath = expand("%:p:r")
endfunction

function! s:pasteExport()
	let relativePath = s:getRelativePath(s:yankedExportAbsPath, expand("%:p"))
	let @" = "import {" . s:yankedExport . "} from '" . relativePath "';"
	normal! p
endfunction

" Public interface

command! -range TipYankExport :call s:yankExport()
command! TipPasteExport :call s:pasteExport()
