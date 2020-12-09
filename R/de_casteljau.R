



#' extract x and y control points from svg cubic bezier parameter string
#' @param str a character vector of strings like "M176.5,-109.927C176.5,-85.4772 176.5,-52.7579 176.5,-38.3437"
#' @return a list with length(str) components, each having xpts and ypts
svg_1cubic_bezier2cpoints <- function(str) {
  tmp <- lapply(str_split(str, "[^0-9.-]+"), function(x) x[-1])
  lapply(tmp, function(x) list(xpts = as.numeric(x[c(1, 3, 5, 7)]), ypts = as.numeric(x[c(2, 4, 6, 8)])))
}

#' return bezier control pts (for either x or y) for internal segment or original curve
#' @param t0 how far along from 0 to 1 to start the segment
#' @param t1 where to end the segment
#' @param pts a vector of length 4 with the control points
bezier_segment_pts <- function(pts, t0, t1) {
  if(t0 > t1) stop("t0 must be less than t1")
  u0 <- 1 - t0
  u1 <- 1 - t1
  
  p1 <- pts[1]
  p2 <- pts[2]
  p3 <- pts[3]
  p4 <- pts[4]
  
  # compute the new ones:
  P1 <- (u0*u0*u0*p1 + (t0*u0*u0 + u0*t0*u0 + u0*u0*t0)*p2 + (t0*t0*u0 + u0*t0*t0 + t0*u0*t0)*p3 + t0*t0*t0*p4)
  P2 <- (u0*u0*u1*p1 + (t0*u0*u1 + u0*t0*u1 + u0*u0*t1)*p2 + (t0*t0*u1 + u0*t0*t1 + t0*u0*t1)*p3 + t0*t0*t1*p4)
  P3 <- (u0*u1*u1*p1 + (t0*u1*u1 + u0*t1*u1 + u0*u1*t1)*p2 + (t0*t1*u1 + u0*t1*t1 + t0*u1*t1)*p3 + t0*t1*t1*p4)
  P4 <- (u1*u1*u1*p1 + (t1*u1*u1 + u1*t1*u1 + u1*u1*t1)*p2 + (t1*t1*u1 + u1*t1*t1 + t1*u1*t1)*p3 + t1*t1*t1*p4)
  
  c(P1, P2, P3, P4)
}



#' given a list like what comes out of svg_1cubic_bezier2cpoints take segments of each and return as xpts and ypts
#' @param L the list of control points
#' @param t0 how far along from 0 to 1 to start the segment
#' @param t1 where to end the segment
bezier_segments <- function(L, t0, t1) {
  lapply(L, function(z) {
    list(xpts = bezier_segment_pts(z$xpts, t0, t1),
         ypts = bezier_segment_pts(z$ypts, t0, t1))
  })
}