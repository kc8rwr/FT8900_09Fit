$fn = $preview ? 36 : 360;

module rounded_square(size, r, center = false){
   translate([center?0:r, center?0:r]){
      minkowski(){
         square([size.x-(2*r), size.y-(2*r)], center=center);
         circle(r = r);
      }
   }
}

module ft8900_face_cutout(){
   rounded_square(size=[139, 37], r=6, center=true); // [138, 36]
   intersection(){
      translate([0, -19]){
         square([138, 5], center=true);
      }
      translate([0, 291-4-18]){
         circle(r=291);
      }
   }
}

module mic_socket_cutout(indent_height = 5, cutout_height=9){
   rotate([0, 180, 0]){
      linear_extrude(indent_height){
         rounded_square(size=[38.5, 21.25], r=8, center=true);
      }
      linear_extrude(cutout_height){
         square([17, 14], center=true);
         for (x = [-14.33, 14.33]){
            translate([x, 0]){
               circle(d=3.25);
            }
         }
      }
   }
}

module switch_cutout(indent_height = 6, cutout_height=9){
   rotate([0, 180, 0]){
      linear_extrude(indent_height){
         rounded_square(size=[38.5, 18], r=3, center=true);
      }
      linear_extrude(cutout_height){
         square([28, 13], center=true);
      }
   }
}

module ft8900_support(left = true){
   mirror([left?0:1, left?0:1, 0]){ 
      translate([left?-2:0, left?0:-2, 0]){
         rotate([90, 0, left?90:180]){
            difference(){
               union(){
                  linear_extrude(height=2){
                     polygon([[0, 29], [26,55], [26, 126], [0, 126]]);
                  }
                  cube([4, 126, 22]);
                  for(z = [22/3-2, 44/3-2]){
                     translate([-1.5, 0, z]){
                        cube([5.5, 126, 4]);
                     }
                  }

                  for (y=[32, 65.5, 100]){
                     translate([0, y, -1]){
                        rotate([0, 0, -45]){
                           translate([-2, 0, 0]){
                              cube([2, 40, 3]);
                           }
                        }
                     }
                  }
               }
               translate([-4, 0, -2]){
                  cube([4, 126, 6]);
                  translate([30, 0, 0]){
                     cube([4, 130, 6]);
                  }
               }
               translate([0, 126, -3]){
                  cube([30, 30, 12]);
               }
               for(y = [62.5, 112.5]){
                  translate([20.25, y, -1]){
                     rotate([0, 0, 0]){
                        cylinder(d=4.2, h=10);
                     }
                  }
               }
            }
         }
      }
   }
}

module clip(height, width, thickness, overhang, center = false, angle=66, ridges=1, support=0, support_spacing=5, gap=0){
   shelf_height = overhang * tan(angle);

   module support(){
      translate([support, -thickness, 0]){
         rotate([90, 0, 270]){
            linear_extrude(height=support){
               if ((shelf_height+gap) >= height){
                  square([overhang, height - gap]);
               } else {
                  polygon([[0, height-(overhang+gap)], [0, height-gap], [overhang, height-gap]]);
               }
            }
         }
      }
   }
   
   points = [
      [0, 0], //bottom back
      [thickness, 0], //bottom front
      [thickness, height], //inside
      [thickness + overhang, height], //shelf point
      [0, height + shelf_height] //top point
   ];
   translate([center?-width/2:0, center?thickness/2:0, 0]){
      translate([width, 0, 0]){
         rotate([90, 0, -90]){
            linear_extrude(height = width){
               polygon(points);
            }
         }
      }
      if (ridges>0){
         area_count = floor(width / 4);
         if (1 == area_count){
            translate([(width/2)-1, 0, 0]){
               cube([2, ridges, height + shelf_height]);
            }
         } else if (1 < area_count){
            area = width / area_count;
            echo(area);
            for(x=[(area/2)-1:area:width]){
               translate([x, 0, 0]){
                  cube([2, ridges, height + shelf_height]);
               }
            }
         } 
      }
      if (0 < support && 0 < support_spacing){
         support_count = floor(width/support_spacing);
         actual_support_spacing = min(width-support, (width-support)/support_count);
         color("grey"){
            for(x = [0:actual_support_spacing:width-support]){
               translate([x, 0, 0]){
                  support();
               }
            }
         }
      }
      
   }
}

//used to cutout a relay profile from the side of one of the support brackets
//not using now because it doesn't fit in the car with the relay mounted on the side
module relay_cutout(height=4, hole=false, center=false){
   translate([0, center?height/2:height, center?13.4:0]){
      rotate([90]){
         linear_extrude(height=height){
            difference(){
               union(){
                  square([28.5, 26.8], center=center);
                  translate([center?0:4.25,center?6.1:0]){
                     square([20, 39], center=center);
                  }
               }
               if (hole){
                  translate([center?0:14.25,center?20:33.4]){
                     circle(d=4.2);
                  }
               }
            }
         }
      }
   }
}

difference(){
   union(){
      linear_extrude(height=7){
         difference(){
            rounded_square(size=[188.5, 106], r=3, center = true);
            translate([0, 25]){
               square([181.5, 52], center=true);
            }
            translate([-2.5, -26]){
               ft8900_face_cutout();
            }
         }
      }
      translate([-74, -48.5, 0]){
         ft8900_support(left=true);
      }
      translate([69, -48.5, 0]){
         ft8900_support(left=false);
      }
   }
   /*translate([-75.75, -61.65, 126.75]){
      rotate([0, 90, 90]){
         relay_cutout(hole=false, center=false, height=4);
      }
   }*/
   translate([80.63, -26, 8]){
      rotate([0, 0, 90]){
         mic_socket_cutout(indent_height=5, cutout_height=9);
     }
   }
   translate([-83.25, -26, 8]){
      rotate([0, 0, 90]){
         switch_cutout(indent_height=5, cutout_height=9);
     }
   }
}

for(v=[[-40.5, 52], [40.5, 52]]){
   translate([v.x, -v.y, 0]){
      clip(height=10.3, width=11.5, overhang=2, thickness=2, center=true, support=1, support_spacing=3);
   }
   translate([v.x, v.y, 0]){
      rotate([0, 0, 180]){
         clip(height=10.3, width=11.5, overhang=2, thickness=2, center=true, ridges=0, support=1, support_spacing=3);
      }
   }
}

