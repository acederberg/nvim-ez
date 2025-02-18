;; extends

; Cannot do injections on comments, since they have no `inner` like strings.
(
  (comment) @comment.mermaid.quarto_metadata
  (#match? @comment.mermaid.quarto_metadata "^\\%\\% ?\\|")
)

