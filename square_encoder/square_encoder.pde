/*
  Square Encoder
  --------------
  This program is able to take any 2d shape defined on a grid and represent it in terms of different sizes of squares.
  
  Controls:
    Left Click - draw shape
    Right Click - erase shape
    SPACE - toggle between the display of individual blocks or just the whole shape
  
  written by Adrian Margel, Spring 2016
*/

class Block {
  //size of the block
  int size=1;

  //position of the block
  int x;
  int y;

  //if the block has just been created
  boolean isNoob=true;
  
  //used to track the growth of the block
  //the first letter C is short for corner
  //the next two letters track denote the which corner the variable is tied to:
  //  second letter is if the corner is negative X (N) or positive X (P)
  //  third letter is if the corner is negative Y (N) or positive Y (P)
  boolean isCPP=false;
  boolean isCPN=false;
  boolean isCNP=false;
  boolean isCNN=false;
  
  //marks if the block is dead / must be deleted
  int dead=0;

  Block(int tx, int ty) {
    x=tx;
    y=ty;
  }
}

//player holds the list of blocks which the shape is made up of
class Player {
  //hue of the player
  int hue;
  //the blocks making up the shape
  ArrayList<Block> blocks=new ArrayList<Block>();

  Player(int tHue) {
    hue=tHue;
  }
  
  //how far two blocks are apart for x
  int xDist(Block b1, Block b2) {
    int tempDist;
    int tempOverlap;
    tempDist=b1.x-b2.x;
    if (tempDist<0) {
      tempDist=-1*(tempDist+b1.size);
      tempOverlap=min(b2.size, (b1.size+b1.x)-b2.x);
    } else {
      tempDist=tempDist-b2.size;
      tempOverlap=min(b1.size, (b2.size+b2.x)-b1.x);
    }
    if (tempDist<0) {
      tempDist=-tempOverlap;
    }
    return tempDist;
  }
  
  //how far two blocks are apart for y
  int yDist(Block b1, Block b2) {
    int tempDist;
    int tempOverlap;
    tempDist=b1.y-b2.y;
    if (tempDist<0) {
      tempDist=-1*(tempDist+b1.size);
      tempOverlap=min(b2.size, (b1.size+b1.y)-b2.y);
    } else {
      tempDist=tempDist-b2.size;
      tempOverlap=min(b1.size, (b2.size+b2.y)-b1.y);
    }
    if (tempDist<0) {
      tempDist=-tempOverlap;
    }
    return tempDist;
  }
  
  //remove overlapping blocks
  void prune() {
    for (int i=blocks.size()-1; i>=0; i--) {
      for (int j=blocks.size()-1; j>=0; j--) {
        //if two blocks are overlapping
        if (xDist(blocks.get(i), blocks.get(j))<0&&yDist(blocks.get(i), blocks.get(j))<0&&i!=j) {
          //remove the smaller block
          if (blocks.get(i).size<blocks.get(j).size) {
            if (blocks.get(i).size==1) {
              //if the block is only one tile large delete it
              blocks.remove(i);
              i--;
              j=blocks.size()-1;
            } else {
              //if the block is larger than one tile break it into smaller blocks
              breakBlock(blocks.get(i));
              blocks.remove(i);
              i--;
              j=blocks.size()-1;
            }
            
          } else {
            if (blocks.get(j).size==1) {
              blocks.remove(j);
              if (j<=i) {
                i--;
              }
            } else {
              breakBlock(blocks.get(j));
              blocks.remove(j);
              if (j<=i) {
                i--;
              }
            }
          }
        }
      }
    }
  }
  
  //break a block into smaller 1 tile large blocks
  void breakBlock(Block brokenBlock) {
    for (int tx=0; tx<brokenBlock.size; tx++) {
      for (int ty=0; ty<brokenBlock.size; ty++) {
        blocks.add(new Block(brokenBlock.x+tx, brokenBlock.y+ty));
      }
    }
  }
  
  //find newly created blocks and test them
  //this tells the program where it needs to run updates
  void findNoobs() {
    for (int i=blocks.size()-1; i>=0; i--) {
      if (blocks.get(i).isNoob) {
        for (int j=blocks.size()-1; j>=0; j--) {
          //if the new block is on the edge of another block
          if ((xDist(blocks.get(i), blocks.get(j))==0&&yDist(blocks.get(i), blocks.get(j))<=0)
            ||(yDist(blocks.get(i), blocks.get(j))==0&&xDist(blocks.get(i), blocks.get(j))<=0)&&i!=j) {
            //if both blocks are alive
            if (blocks.get(i).dead==0&&blocks.get(j).dead==0) {
              //test the block that the new block is touching to see if it is able to grow
              test(blocks.get(j));
            }
          }
        }
        //mark that the new block has now been tested
        blocks.get(i).isNoob=false;
      }
    }
    
    //remove dead blocks
    for (int i=blocks.size()-1; i>=0; i--) {
      if (blocks.get(i).dead==2) {
        if (blocks.get(i).size==1) {
          //freeBlocks.add(new block(blocks.get(i).x+round(x), blocks.get(i).y+round(y)));
          //blocks.remove(i);
        } else {
          breakBlock(blocks.get(i));
          blocks.remove(i);
        }
      }
    }
  }
  //test a block and if it is able to grow then allow it to grow
  void test(Block testedBlock) {
    int CPP=0;
    int CPN=0;
    int CNP=0;
    int CNN=0;
    int PX=0;
    int NX=0;
    int PY=0;
    int NY=0;
    for (int i=blocks.size()-1; i>=0; i--) {
      if (blocks.get(i).dead==0) {
        if (blocks.get(i).dead==0&&blocks.get(i).size<=testedBlock.size) {
          if (xDist(testedBlock, blocks.get(i))==0&&testedBlock.x>blocks.get(i).x) {//find edges touching
            if (yDist(testedBlock, blocks.get(i))<0) {
              blocks.get(i).dead=1;
              PX-=yDist(testedBlock, blocks.get(i));
            }
          } else if (xDist(testedBlock, blocks.get(i))==0&&testedBlock.x<blocks.get(i).x) {
            if (yDist(testedBlock, blocks.get(i))<0) {
              blocks.get(i).dead=1;
              NX-=yDist(testedBlock, blocks.get(i));
            }
          } else if (yDist(testedBlock, blocks.get(i))==0&&testedBlock.y>blocks.get(i).y) {
            if (xDist(testedBlock, blocks.get(i))<0) {
              blocks.get(i).dead=1;
              PY-=xDist(testedBlock, blocks.get(i));
            }
          } else if (yDist(testedBlock, blocks.get(i))==0&&testedBlock.y<blocks.get(i).y) {
            if (xDist(testedBlock, blocks.get(i))<0) {
              blocks.get(i).dead=1;
              NY-=xDist(testedBlock, blocks.get(i));
            }
          }

          if (xDist(testedBlock, blocks.get(i))==0&&testedBlock.x>blocks.get(i).x) {//find corners
            if (yDist(testedBlock, blocks.get(i))<=0) {
              if (testedBlock.y>blocks.get(i).y) {
                blocks.get(i).dead=1;
                if (!blocks.get(i).isCPP) {
                  blocks.get(i).isCPP=true;
                  CPP++;
                }
              }
              if (testedBlock.y+testedBlock.size<blocks.get(i).y+blocks.get(i).size) {
                blocks.get(i).dead=1;
                if (!blocks.get(i).isCPN) {
                  blocks.get(i).isCPN=true;
                  CPN++;
                }
              }
            }
          } else if (xDist(testedBlock, blocks.get(i))==0&&testedBlock.x<blocks.get(i).x) {
            if (yDist(testedBlock, blocks.get(i))<=0) {
              if (testedBlock.y>blocks.get(i).y) {
                blocks.get(i).dead=1;
                if (!blocks.get(i).isCNP) {
                  blocks.get(i).isCNP=true;
                  CNP++;
                }
              }
              if (testedBlock.y+testedBlock.size<blocks.get(i).y+blocks.get(i).size) {
                blocks.get(i).dead=1;
                if (!blocks.get(i).isCNN) {
                  blocks.get(i).isCNN=true;
                  CNN++;
                }
              }
            }
          }
          if (yDist(testedBlock, blocks.get(i))==0&&testedBlock.y>blocks.get(i).y) {
            if (xDist(testedBlock, blocks.get(i))<=0) {
              if (testedBlock.x>blocks.get(i).x) {
                blocks.get(i).dead=1;
                if (!blocks.get(i).isCPP) {
                  blocks.get(i).isCPP=true;
                  CPP++;
                }
              }
              if (testedBlock.x+testedBlock.size<blocks.get(i).x+blocks.get(i).size) {
                blocks.get(i).dead=1;
                if (!blocks.get(i).isCNP) {
                  blocks.get(i).isCNP=true;
                  CNP++;
                }
              }
            }
          } else if (yDist(testedBlock, blocks.get(i))==0&&testedBlock.y<blocks.get(i).y) {
            if (xDist(testedBlock, blocks.get(i))<=0) {
              if (testedBlock.x>blocks.get(i).x) {
                blocks.get(i).dead=1;
                if (!blocks.get(i).isCPN) {
                  blocks.get(i).isCPN=true;
                  CPN++;
                }
              }
              if (testedBlock.x+testedBlock.size<blocks.get(i).x+blocks.get(i).size) {
                blocks.get(i).dead=1;
                if (!blocks.get(i).isCNN) {
                  blocks.get(i).isCNN=true;
                  CNN++;
                }
              }
            }
          }//-----------
        }
      }
    }
    if (CPP>=1&&PX==testedBlock.size&&PY==testedBlock.size) {//still need to remove corners
      for (int i=blocks.size()-1; i>=0; i--) {
        if (blocks.get(i).dead==1) {
          if ((xDist(testedBlock, blocks.get(i))==0&&yDist(testedBlock, blocks.get(i))<0&&testedBlock.x-blocks.get(i).x>0)
            ||(yDist(testedBlock, blocks.get(i))==0&&xDist(testedBlock, blocks.get(i))<0&&testedBlock.y-blocks.get(i).y>0)) {
            blocks.get(i).dead=2;
          } else {//if corner
            if (blocks.get(i).isCPP) {
              blocks.get(i).dead=2;
            }
          }
        }
      }
      testedBlock.x--;
      testedBlock.y--;
      testedBlock.size++;
      testedBlock.isNoob=true;
    } else if (CNP>=1&&NX==testedBlock.size&&PY==testedBlock.size) {
      for (int i=blocks.size()-1; i>=0; i--) {
        if (blocks.get(i).dead==1) {
          if ((xDist(testedBlock, blocks.get(i))==0&&yDist(testedBlock, blocks.get(i))<0&&testedBlock.x<blocks.get(i).x)
            ||(yDist(testedBlock, blocks.get(i))==0&&xDist(testedBlock, blocks.get(i))<0&&testedBlock.y>blocks.get(i).y)) {
            blocks.get(i).dead=2;
          } else {//if corner
            if (blocks.get(i).isCNP) {
              blocks.get(i).dead=2;
            }
          }
        }
      }
      testedBlock.y--;
      testedBlock.size++;
      testedBlock.isNoob=true;
    } else if (CPN>=1&&PX==testedBlock.size&&NY==testedBlock.size) {
      for (int i=blocks.size()-1; i>=0; i--) {
        if (blocks.get(i).dead==1) {
          if ((xDist(testedBlock, blocks.get(i))==0&&yDist(testedBlock, blocks.get(i))<0&&testedBlock.x>blocks.get(i).x)
            ||(yDist(testedBlock, blocks.get(i))==0&&xDist(testedBlock, blocks.get(i))<0&&testedBlock.y<blocks.get(i).y)) {
            blocks.get(i).dead=2;
          } else {//if corner
            if (blocks.get(i).isCPN) {
              blocks.get(i).dead=2;
            }
          }
        }
      }
      testedBlock.x--;
      testedBlock.size++;
      testedBlock.isNoob=true;
    } else if (CNN>=1&&NX==testedBlock.size&&NY==testedBlock.size) {
      for (int i=blocks.size()-1; i>=0; i--) {
        if (blocks.get(i).dead==1) {
          if ((xDist(testedBlock, blocks.get(i))==0&&yDist(testedBlock, blocks.get(i))<0&&testedBlock.x<blocks.get(i).x)
            ||(yDist(testedBlock, blocks.get(i))==0&&xDist(testedBlock, blocks.get(i))<0&&testedBlock.y<blocks.get(i).y)) {
            blocks.get(i).dead=2;
          } else {//if corner
            if (blocks.get(i).isCNN) {
              blocks.get(i).dead=2;
            }
          }
        }
      }
      testedBlock.size++;
      testedBlock.isNoob=true;
    }
    for (int i=blocks.size()-1; i>=0; i--) {
      blocks.get(i).isCPP=false;
      blocks.get(i).isCNP=false;
      blocks.get(i).isCPN=false;
      blocks.get(i).isCNN=false;
      if (blocks.get(i).dead==1) {
        blocks.get(i).dead=0;
      }
    }
  }
  
  //display all blocks
  void display() {
    fill(hue, 200, 200, 200);
    if (showLines) {
      stroke(hue, 200, 100, 200);
      strokeWeight(zoom/5);
    } else {
      noStroke();
    }
    for (int i=0; i<blocks.size(); i++) {
      fill(hue, 200, 200, 200);
      rect((blocks.get(i).x)*zoom, (blocks.get(i).y)*zoom, 
        blocks.get(i).size*zoom, blocks.get(i).size*zoom);
    }
  }
}
//the shape the player is creating
Player p1;
//text font
PFont font;
//display zoom
float zoom=10;


//if the player has done anything yet
boolean hasStarted=false;
//variables used for making the initial text flash
int start1=0;
int start2=1;

void setup() {
  //setup stuff
  font=createFont("Arail", 30);
  textFont(font);
  size(800, 800);
  colorMode(HSB);
  
  //create player as random color
  p1=new Player((int)random(0, 255));
}

void draw() {
  //clear screen
  background(255);
  //show where the player will draw or erase if they click
  fill(0, 10);
  noStroke();
  rect(round(mouseX/zoom-5)*zoom, round(mouseY/zoom-5)*zoom, 10*zoom, 10*zoom);
  
  //display instructions
  if (!hasStarted) {
    start1+=start2;
    if (start1+start2>200) {
      start2=-2;
    } else if (start1+start2<50) {
      start2=2;
    }
    fill(start1);
    text("left click and drag to draw,right click and drag to erase", 50, 100);
  }
  
  //add blocks
  if (leftDown) {
    for (int x=-5; x<5; x++) {
      for (int y=-5; y<5; y++) {
        p1.blocks.add(new Block(round(mouseX/zoom+x), round(mouseY/zoom+y)));
      }
    }
  }
  
  //erase blocks
  if (rightDown) {
    for (int x=-5; x<5; x++) {
      for (int y=-5; y<5; y++) {
        for (int i=p1.blocks.size()-1; i>=0; i--) {
          if (p1.blocks.get(i).x<=mouseX/zoom+x&&p1.blocks.get(i).x+p1.blocks.get(i).size>=mouseX/zoom+x&&
            p1.blocks.get(i).y<=mouseY/zoom+y&&p1.blocks.get(i).y+p1.blocks.get(i).size>=mouseY/zoom+y) {
            if (p1.blocks.get(i).size>1) {
              p1.breakBlock(p1.blocks.get(i));
            }
            p1.blocks.remove(i);
          }
        }
      }
    }
  }
  
  //run logic to merge and handle blocks
  p1.prune();
  p1.findNoobs();
  p1.prune();
  p1.display();
}

//user input
boolean rightDown=false;
boolean leftDown=false;
boolean showLines=true;
void keyPressed() {
  if (key==' ') {
    if (showLines) {
      showLines=false;
    } else {
      showLines=true;
    }
  }
}
void mousePressed() {
  hasStarted=true;
  if (mouseButton == RIGHT) {
    rightDown=true;
  }
  if (mouseButton == LEFT) {
    leftDown=true;
  }
}
void mouseReleased() {
  if (mouseButton == RIGHT) {
    rightDown=false;
  }
  if (mouseButton == LEFT) {
    leftDown=false;
  }
}
