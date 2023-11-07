import React, { Component } from 'react';
import { getConfig, getVisibleCanvasCaptions, getVisibleCanvasVideoResources } from '@columbia-libraries/mirador/dist/es/src/state/selectors';
import { connect } from 'react-redux';
import { compose } from 'redux';
import { withTranslation } from 'react-i18next';

import VideoJS from './VideoJS';

/** */
const mapStateToProps = (state, { windowId }) => (
  {
    captions: getVisibleCanvasCaptions(state, { windowId }) || [],
    videoOptions: getConfig(state).videoOptions,
    videoResources: getVisibleCanvasVideoResources(state, { windowId }) || [],
  }
);

const enhance = compose(
  withTranslation(),
  connect(mapStateToProps, null),
);

class VideoJSViewerBase extends Component {
  render() {
    const {
      captions, videoOptions, videoResources,
    } = this.props;

    console.log({props: this.props})
    const videoJsOptions = {
      playbackRates: [0.5, 1, 1.5, 2],
      controlBar: {
        remainingTimeDisplay: false
      },
      autoplay: false,
      controls: true,
      responsive: true,
      fluid: true,
      sources: videoResources.filter(video => video.id && video.getFormat()).map(video => ({ src: video.id, type: video.getFormat() })),
      tracks: captions.filter(caption => caption.id).map(caption => ({ kind: (caption.kind || 'captions'), src: caption.id })),
    };

    if (videoJsOptions.sources.length == 0) return <div id="empty-video"></div>;
    return (
      <div className="video-js w-100" data-vjs-player>
        <VideoJS options={videoJsOptions} />
      </div>
    );
  }
}

export const VideoJSViewer = enhance(VideoJSViewerBase);

/** */
export default function ({ _targetComponent, targetProps  }) {
  return <VideoJSViewer {...targetProps} />;
}
