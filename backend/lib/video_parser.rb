class VideoParser
  def self.parse_playwire_video (script_node)
    return nil if script_node.is_a?(String) && script_node.empty?

    script_node = [script_node] if !script_node.is_a?(Array)

    return {
      type: 'playwire',
      data: {
        publisher_id: script_node.first.attr('data-publisher-id'),
        video_id:     script_node.first.attr('data-video-id'),
        video_config: script_node.first.attr('data-config')
      }
    }
  end

  def self.parse_sapo_videos (iframe_node)
    return {} if !iframe_node.length

    iframe_node = iframe_node.first
    {
      type: 'sapo',
      data: {
        html: iframe_node.to_s
      }
    }
  end
end
