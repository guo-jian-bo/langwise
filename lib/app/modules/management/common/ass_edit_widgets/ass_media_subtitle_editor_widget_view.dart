part of 'ass_media_subtitle_editor_widget.dart';

extension _AssMediaSubtitleEditorWidgetViewMethods
    on _AssMediaSubtitleEditorWidgetState {
  Widget _buildRoot() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SizedBox.expand(
            child: Column(
              children: <Widget>[
                Expanded(child: _buildBody()),
                Column(
                  children: [
                    SizedBox(
                      child: widget.envelopeTopFloatWidget,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBottomPlayerBar(),
                        ),
                        if(_videoController != null && widget.mediaType == ResourceTypeEnum.video) Container(
                          margin: EdgeInsets.only(left: 10.wMin),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.wMin),
                            child: Container(
                              width: 200.wMin,
                              height: 200.wMin,
                              color: AppTheme.cSurfaceSecondary.color,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Video(
                                    controller: _videoController!,
                                    aspectRatio: 1,
                                    controls: (state) {
                                      return Container();
                                    },
                                  ),
                                  if (!_isVideoReady)
                                    Container(
                                      color: AppTheme.cSurfaceSecondary.color,
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 24.wMin,
                                        height: 24.wMin,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.wMin,
                                          color: AppTheme.cTextBrand.color,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
