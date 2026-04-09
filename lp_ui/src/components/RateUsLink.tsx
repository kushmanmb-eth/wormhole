import { Link, makeStyles, Typography } from "@material-ui/core";
import StarIcon from "@material-ui/icons/Star";

const useStyles = makeStyles((theme) => ({
  container: {
    position: "fixed",
    bottom: 20,
    right: 20,
    backgroundColor: theme.palette.primary.main,
    color: "white",
    padding: "12px 20px",
    borderRadius: "8px",
    boxShadow: "0 4px 6px rgba(0, 0, 0, 0.1)",
    display: "flex",
    alignItems: "center",
    gap: "8px",
    cursor: "pointer",
    transition: "all 0.3s ease",
    "&:hover": {
      backgroundColor: theme.palette.primary.dark,
      boxShadow: "0 6px 12px rgba(0, 0, 0, 0.15)",
      transform: "translateY(-2px)",
    },
    zIndex: 1000,
  },
  icon: {
    fontSize: "20px",
  },
  text: {
    fontWeight: 600,
    fontSize: "14px",
    color: "white",
  },
  link: {
    textDecoration: "none",
    color: "inherit",
  },
}));

function RateUsLink() {
  const classes = useStyles();

  const handleClick = () => {
    // Track rating link click (can integrate with analytics)
    if (typeof window !== "undefined" && (window as any).gtag) {
      (window as any).gtag("event", "rate_us_click", {
        event_category: "engagement",
        event_label: "rate_us_link",
      });
    }
  };

  return (
    <Link
      href="https://github.com/wormhole-foundation/wormhole/blob/main/RATE_US.md"
      target="_blank"
      rel="noopener noreferrer"
      className={classes.link}
      onClick={handleClick}
    >
      <div className={classes.container}>
        <StarIcon className={classes.icon} />
        <Typography className={classes.text}>Rate Us</Typography>
      </div>
    </Link>
  );
}

export default RateUsLink;
