;; -*- mode: lisp; coding: utf-8-unix -*-
;;
;; This file is part of emacs initialization files
;; It is repsonsible to setup runtime environment for emacs
;;


;; OS type -- are we running Microsoft Windows?
(defvar running-ms-windows (eq system-type 'windows-nt))

; Set PATH depending on operating system being run
(defun getappdata ()
  (getenv "LOCALAPPDATA"))

(if running-ms-windows
    (progn
      (setenv "PATH"
              (concat
               (getappdata) "\\GnuWin32\\bin" ";"
               (getappdata) "\\PortableGit\\bin\\" ";"
               (getappdata) "\\doxygen\\bin" ";"
               "C:\\Program Files\\Java\\jdk1.7.0\\bin" ";"
               (getenv "PATH")
               )
              )
      (add-to-list 'exec-path (concat (getappdata) "/PortableGit/bin/"))
      (add-to-list 'exec-path (concat (getappdata) "/GnuWin32/bin/"))
      (add-to-list 'exec-path (concat (getappdata) "/doxygen/bin/"))
      (add-to-list 'exec-path "C:/Program Files/Java/jdk1.7.0/bin")
      )
  )

(if (eq system-type 'gnu/linux)         ; todo recongnize properly our dev server
    (progn
      (setenv "PATH"
              (concat
               "/opt/graphviz/linux/ix86/graphviz_2.16.1/bin" ":"
               "/opt/doxygen/linux/ix86/doxygen_1.5.8-rhel4/bin" ":"
               (getenv "PATH")
               )
              )
      (add-to-list 'exec-path "/opt/graphviz/linux/ix86/graphviz_2.16.1/bin")
      (add-to-list 'exec-path "/opt/doxygen/linux/ix86/doxygen_1.5.8-rhel4/bin")
      )
  )
