function char = dependencies(mfile)

%generate a space-delimited list of the user-created dependencies of an
%M-file. This is used for makefiles.
if ~isempty(mfile)
    p = fdep(mfile, '-q');
    try
        char = join(' ', {which(mfile), p.fun{:}});
    catch
        char = '';
    end
else
    char = '';
end

assignin('caller', 'response', char)