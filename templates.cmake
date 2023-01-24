function(render_template input output)
  configure_file(
    "${input}" "${output}"
    @ONLY
    NEWLINE_STYLE UNIX
  )
endfunction()

include("${TEMPLATES_DIR}/hooks.cmake")
