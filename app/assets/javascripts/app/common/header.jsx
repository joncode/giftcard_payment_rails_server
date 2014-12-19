/** @jsx React.DOM */

var Brand = React.createClass({
  render: function() {
    return this.transferPropsTo(
      <NavHeader>
        <NavBrand tabIndex='-1'>
          <img src='/imgs/PT_logo_wht.png' alt='PTLogo' width='143' height='29' />
        </NavBrand>
      </NavHeader>
    );
  }
});

var Skins = React.createClass({
  statics: {
    skins: ['default', 'green', 'blue', 'purple', 'brown', 'cyan']
  },
  switchSkin: function(skin, e) {
    e.preventDefault();
    e.stopPropagation();
    for(var i=0; i < Skins.skins.length; i++) {
      $('html').removeClass(Skins.skins[i]);
    }
    $('html').addClass(skin);
    vex.close(this.props.id);
  },
  render: function() {
    return (
      <Grid style={{margin: '-2em'}}>
        <Row>
          <Col xs={12} className='text-center bg-darkgrayishblue75' style={{marginBottom: 25}}>
            <div className='fg-white' style={{fontSize: 24, lineHeight: 1, padding: '25px 10px'}}>
              Choose a theme:
            </div>
          </Col>
        </Row>
        <Row>
          <Col xs={4} className='text-center'>
            <a href='#' style={{border: 'none'}} onClick={this.switchSkin.bind(this, 'default')}>
              <Icon glyph='icon-fontello-stop icon-4x' style={{color: '#E76049'}} />
            </a>
          </Col>
          <Col xs={4} className='text-center'>
            <a href='#' style={{border: 'none'}} onClick={this.switchSkin.bind(this, 'green')}>
              <Icon glyph='icon-fontello-stop icon-4x' className='fg-darkgreen45' />
            </a>
          </Col>
          <Col xs={4} className='text-center'>
            <a href='#' style={{border: 'none'}} onClick={this.switchSkin.bind(this, 'blue')}>
              <Icon glyph='icon-fontello-stop icon-4x' className='fg-blue' />
            </a>
          </Col>
        </Row>
        <Row>
          <Col xs={4} className='text-center'>
            <a href='#' style={{border: 'none'}} onClick={this.switchSkin.bind(this, 'purple')}>
              <Icon glyph='icon-fontello-stop icon-4x' className='fg-purple' />
            </a>
          </Col>
          <Col xs={4} className='text-center'>
            <a href='#' style={{border: 'none'}} onClick={this.switchSkin.bind(this, 'brown')}>
              <Icon glyph='icon-fontello-stop icon-4x' className='fg-brown' />
            </a>
          </Col>
          <Col xs={4} className='text-center'>
            <a href='#' style={{border: 'none'}} onClick={this.switchSkin.bind(this, 'cyan')}>
              <Icon glyph='icon-fontello-stop icon-4x' className='fg-darkcyan' />
            </a>
          </Col>
        </Row>
      </Grid>
    );
  }
});

var Navigation = React.createClass({
  handleLogout: function() {
    $('body').addClass('fade-out');
    setTimeout(function() {
      RRouter.routing.navigate('/');
    }.bind(this), 250);
  },
  render: function() {
    for(var i=0; i < Skins.skins.length; i++) {
      $('html').removeClass(Skins.skins[i]);
    }
    $('html').addClass('cyan');
    return this.transferPropsTo(
      <NavContent className='pull-right'>
        <Nav>
          <NavItem className='logout' href='#' onClick={this.handleLogout}>
            <Icon bundle='fontello' glyph='off-1' />
          </NavItem>
        </Nav>
      </NavContent>
    );
  }
});

var Header = React.createClass({
  render: function() {
    return this.transferPropsTo(
      <Grid id='navbar'>
        <Row>
          <Col xs={12}>
            <NavBar fixedTop id='rubix-nav-header'>
              <Container fluid>
                <Row>
                  <Col xs={3} visible='xs'>
                    <SidebarBtn />
                  </Col>
                  <Col xs={6} sm={4}>
                    <Brand />
                  </Col>
                  <Col xs={3} sm={8}>
                    <Navigation pressed={this.props.pressed} />
                  </Col>
                </Row>
              </Container>
            </NavBar>
          </Col>
        </Row>
      </Grid>
    );
  }
});

module.exports = Header;
