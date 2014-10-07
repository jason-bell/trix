#= require trix/utilities/object
#= require trix/utilities/hash

class Trix.Attachment extends Trix.Object
  @attachmentForFile: (file) ->
    attachment = new this @attributesForFile(file)
    attachment.file = file
    attachment

  @attributesForFile: (file) ->
    new Trix.Hash
      filename:    file.name
      filesize:    file.size
      contentType: file.type

  @fromJSON: (attachmentJSON) ->
    new this attachmentJSON

  constructor: (attributes = {}) ->
    super
    @attributes = Trix.Hash.box(attributes)

  getAttribute: (attribute) ->
    @attributes.get(attribute)

  getAttributes: ->
    @attributes.toObject()

  setAttributes: (attributes = {}) ->
    newAttributes = @attributes.merge(attributes)
    unless @attributes.isEqualTo(newAttributes)
      @attributes = newAttributes
      @delegate?.attachmentDidChange?(this)

  setUploadProgress: (value) ->
    unless value is @uploadProgress
      @uploadProgress = value
      @delegate?.attachmentDidChange?(this)

  getUploadProgress: ->
    @uploadProgress ? 0

  isPending: ->
    @file? and not @getURL()

  isImage: ->
    /image/.test(@getContentType())

  getURL: ->
    @attributes.get("url")

  getFilename: ->
    @attributes.get("filename") ? "Untitled"

  getFilesize: ->
    @attributes.get("filesize") ? 0

  getExtension: ->
    @getFilename().match(/\.(\w+)$/)?[1].toLowerCase()

  getContentType: ->
    @attributes.get("contentType")

  getPreviewURL: (callback) ->
    if @previewURL?
      callback(@previewURL)
    else if @file?
      reader = new FileReader
      reader.onload = (event) =>
        return unless @file?
        callback(@previewURL = event.target.result)
      reader.readAsDataURL(@file)

  toJSON: ->
    @attributes

  toKey: ->
    [super, @attributes.toKey()].join("/")
