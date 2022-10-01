import Image from "next/image";
import styles from "../styles/Home.module.css";
import { useMoralisQuery, useMoralis } from "react-moralis";
import NFTBox from "../components/NFTBox";

export default function Home() {
  const { isWeb3Enabled } = useMoralis();
  const { data: listedNfts, isFetching: fetchingListedNfts } = useMoralisQuery(
    // TableName
    // Function for the query
    "ActiveItem",
    (query) => query.limit(10).descending("tokenId")
  );
  console.log(listedNfts.attributes);

  // {fetchingListedNfts ? (<div>Loading</div>) : listedNfts.map()}
  return (
    <div className="container mx-auto">
      <h1 className="py-4 px-4 font-bold text-2xl">Recently Listed</h1>
      <div className="flex flex-wrap">
        {isWeb3Enabled ? (
          fetchingListedNfts ? (
            <div>Loading</div>
          ) : (
            listedNfts.map((nft) => {
              console.log(nft.attributes);
              const { price, nftAddress, tokenId, marketplaceAddress, seller } =
                nft.attributes;
              return (
                <div>
                  {/* Price: {price}. NftAddress: {nftAddress}. tokenId:{tokenId}.
                seller:{seller} */}
                  <NFTBox
                    price={price}
                    nftAddress={nftAddress}
                    tokenId={tokenId}
                    marketplaceAddress={marketplaceAddress}
                    seller={seller}
                    key={`${nftAddress}${tokenId}`}
                  />
                </div>
              );
            })
          )
        ) : (
          <div>Web 3 currently is not enabled</div>
        )}
      </div>
    </div>
  );
}

// import Image from "next/image";
// import styles from "../styles/Home.module.css";
// import { useMoralisQuery, useMoralis } from "react-moralis";

// export default function Home() {
//   // we will index the event off-chain and then read from our database
//   // setup a server to listen for those event to be fired, and we will add them to database to query

//   const { data: listedNfts, isFetching: fetchingListedNfts } = useMoralisQuery(
//     // TableName
//     // Function for the query
//     "ActiveItem",
//     (query) => query.limit(10).descending("tokenId")
//   );
//   console.log(listedNfts);

//   return (<div className={styles.container}>Hi</div>);
// }

// // DDqeCA4hfdROJ5V9VJSxxuwqzY2PFEobxlNw2WMjc6n3iOkKmDib0POPNRGne135
