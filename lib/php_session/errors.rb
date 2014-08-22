# -*- coding: utf-8 -*-
class PHPSession::Errors < StandardError; end
class PHPSession::Errors::ParameterError < StandardError; end
class PHPSession::Errors::ParseError < PHPSession::Errors; end
class PHPSession::Errors::EncodeError < PHPSession::Errors; end
