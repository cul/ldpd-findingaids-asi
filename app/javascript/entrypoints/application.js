// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "../controllers"
import bootstrap from "bootstrap"
import githubAutoCompleteElement from "@github/auto-complete-element"
import Blacklight from "blacklight"

import "arclight/arclight.js";

import Mirador from '@columbia-libraries/mirador/dist/es/src';
import VideoJsPlugin from "../mirador-videojs"

function initMirador() {
  let miradorDiv = document.querySelector("#mirador");
  if (!miradorDiv) return;
  let manifestUrl = miradorDiv.dataset.manifest;
  if (!manifestUrl) return;
  console.log({manifestUrl});

  Mirador.viewer(
    {
      id: 'mirador',
      window: {
        allowClose: false,
        allowFullscreen: true,
        panels: {
          info: true,
          canvas: true
        },
      },
      windows: [
        {
          manifestId: manifestUrl
        }
      ],
      workspace: {
        showZoomControls: true,
      },
      workspaceControlPanel: {
        enabled: false
      },
      miradorDownloadPlugin: {
        restrictDownloadOnSizeDefinition: true,
      }
    },
    [VideoJsPlugin[0]]
  );
}

document.addEventListener("DOMContentLoaded", initMirador);
