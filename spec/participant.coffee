
msgflo = require '../'
participants = require './fixtures/participants'

chai = require 'chai' unless chai

describe 'Participant', ->
  address = 'direct://broker3'

  describe 'Source participant', ->
    source = null
    beforeEach () ->
      source = participants.FooSource msgflo.transport.getClient address

    it 'has inports without queues', ->
      ports = source.definition.inports
      chai.expect(ports).to.have.length 1
      chai.expect(ports[0].id).to.equal 'interval'
      chai.expect(ports[0].queue).to.be.a 'undefined'
    it 'has outports with queues', ->
      ports = source.definition.outports
      chai.expect(ports).to.have.length 1
      chai.expect(ports[0].id).to.equal 'out'
      chai.expect(ports[0].queue).to.be.a 'string'
      chai.expect(ports[0].queue).to.contain 'foosource'
      chai.expect(ports[0].queue).to.contain 'outputq'
    describe 'running data', ->
      messages = []
      beforeEach (done) ->
        broker = msgflo.transport.getBroker address
        broker.connect (err) ->
          chai.expect(err).to.be.a 'null'
          source.start done
      it 'does nothing when just started'
        

      it 'produces data when sending interval=100', (done) ->
        onOutput = (msg) ->
          messages.push msg
          done() if messages.length == 3
        observer = msgflo.transport.getClient address
        observer.connect (err) ->
          chai.expect(err).to.be.a 'null'
          port = source.definition.outports[0] # out
          observer.subscribeToQueue port.queue, onOutput, (err) ->
            chai.expect(err).to.be.a 'null'
          source.send 'interval', 100
      it 'stops producing when sending interval=0'


  describe 'Transform participant', ->
    source = null
    beforeEach () ->
      source = participants.Hello msgflo.transport.getClient address
    it 'has inports with queues', ->
      ports = source.definition.inports
      chai.expect(ports).to.have.length 1
      chai.expect(ports[0].id).to.equal 'name'
      chai.expect(ports[0].queue).to.be.a 'string'
      chai.expect(ports[0].queue).to.contain 'hello'
      chai.expect(ports[0].queue).to.contain 'inputq'
    it 'has outports with queues', ->
      ports = source.definition.outports
      chai.expect(ports).to.have.length 1
      chai.expect(ports[0].id).to.equal 'out'
      chai.expect(ports[0].queue).to.be.a 'string'
      chai.expect(ports[0].queue).to.contain 'hello'
      chai.expect(ports[0].queue).to.contain 'outputq'
    describe 'sending data on input queue', ->
      it 'produces data on output queue'


  describe 'Sink participant', ->
    sink = null
    beforeEach (done) ->
      sink = participants.DevNullSink msgflo.transport.getClient address
      sink.start done
    afterEach (done) ->
      sink.stop done

    it 'has inports with queues', ->
      ports = sink.definition.inports
      chai.expect(ports).to.have.length 1
      chai.expect(ports[0].id).to.equal 'drop'
      chai.expect(ports[0].queue).to.be.a 'string'
      chai.expect(ports[0].queue).to.contain 'devnullsink'
      chai.expect(ports[0].queue).to.contain 'drop'
    it 'has outports without queues', ->
      ports = sink.definition.outports
      chai.expect(ports).to.have.length 1
      chai.expect(ports[0].id).to.equal 'dropped'
      chai.expect(ports[0].queue).to.be.a 'undefined'
    describe 'sending data on input queue', ->
      it 'produces data on output port', (done) ->
        sink.on 'data', (outport, data) ->
          chai.expect(outport).to.equal 'dropped'
          chai.expect(data).to.equal 'myinput32'
          done()
        sink.send 'drop', "myinput32", () ->

