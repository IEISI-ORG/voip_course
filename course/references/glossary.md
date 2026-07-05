# VoIPSec Glossary — Abbreviations & Acronyms

Companion to the [bibliography](bibliography.md). Spell out each term on first use per module,
then abbreviate. (References themselves will be revisited later per user note.)

## Protocols & core
- **SIP** — Session Initiation Protocol
- **SDP** — Session Description Protocol
- **RTP / RTCP** — Real-time Transport Protocol / RTP Control Protocol
- **SRTP** — Secure RTP
- **DTLS** — Datagram Transport Layer Security
- **TLS / SIPS** — Transport Layer Security / SIP-Secure (SIP over TLS)
- **ZRTP** — Zimmermann RTP (media key agreement)
- **UAC / UAS** — User Agent Client / Server
- **B2BUA** — Back-to-Back User Agent
- **AoR** — Address of Record
- **PAI** — P-Asserted-Identity

## Infrastructure & edge
- **PBX** — Private Branch Exchange
- **SBC** — Session Border Controller
- **PSTN** — Public Switched Telephone Network
- **ITSP** — Internet Telephony Service Provider
- **NAT** — Network Address Translation
- **STUN / TURN / ICE** — Session Traversal Utilities for NAT / Traversal Using Relays around NAT
  / Interactive Connectivity Establishment
- **DID** — Direct Inward Dialing (number)
- **HA** — High Availability
- **VIP** — Virtual IP
- **DMQ** — Distributed Message Queue (Kamailio state replication)

## Identity, fraud & security
- **STIR/SHAKEN** — Secure Telephone Identity Revisited / Signature-based Handling of Asserted
  information using toKENs
- **PASSporT** — Personal Assertion Token
- **RCD** — Rich Call Data
- **TNAuthList** — Telephone Number Authorization List (cert extension)
- **CA** — Certificate Authority
- **mTLS** — mutual TLS
- **SRI** — Subresource Integrity
- **XXE** — XML External Entity (attack)
- **IRSF** — International Revenue Share Fraud
- **DoS / DDoS** — Denial of Service / Distributed DoS
- **SSRF** — Server-Side Request Forgery
- **RBAC** — Role-Based Access Control
- **SIEM** — Security Information and Event Management
- **IR** — Incident Response
- **CDR** — Call Detail Record
- **PCI-DSS** — Payment Card Industry Data Security Standard
- **PAN** — Primary Account Number (card)
- **PII** — Personally Identifiable Information

## Media, fax, mobile & emergency
- **DTMF** — Dual-Tone Multi-Frequency (touch-tone)
- **MOS** — Mean Opinion Score
- **QoS / DSCP** — Quality of Service / Differentiated Services Code Point
- **FoIP / T.38** — Fax over IP / ITU-T real-time fax protocol
- **VoLTE / VoNR / IMS** — Voice over LTE / New Radio / IP Multimedia Subsystem
- **ENUM** — E.164 Number Mapping (telephone numbers in DNS)
- **PIDF-LO** — Presence Information Data Format — Location Object
- **NG911 / PSAP** — Next-Generation 911 / Public Safety Answering Point
- **UC / UCaaS / CPaaS** — Unified Communications / UC-as-a-Service / Communications Platform-as-a-Service

## DNS & infrastructure
- **NAPTR / SRV** — Naming Authority Pointer / Service (DNS records)
- **DNSSEC** — DNS Security Extensions
- **DoT / DoH** — DNS over TLS / DNS over HTTPS
- **HEP** — Homer Encapsulation Protocol (capture)
- **IaC** — Infrastructure as Code
- **PSS** — Pod Security Standards (Kubernetes)
- **CI** — Continuous Integration

## Additional terms (consistency audit G5)
- **ALG** — Application-Layer Gateway (e.g. SIP ALG on routers)
- **SDES** — Session Description Protocol Security Descriptions (in-band SRTP keying)
- **SAS** — Short Authentication String (ZRTP)
- **AEAD** — Authenticated Encryption with Associated Data
- **AES-GCM** — Advanced Encryption Standard — Galois/Counter Mode
- **HMAC** — Hash-based Message Authentication Code
- **MD5** — Message-Digest 5 (legacy hash; weak)
- **JWT** — JSON Web Token
- **HSM** — Hardware Security Module
- **SNI** — Server Name Indication (TLS)
- **CORS** — Cross-Origin Resource Sharing
- **MITM** — Man-in-the-Middle (attack)
- **IDS / IPS** — Intrusion Detection / Prevention System
- **WAF** — Web Application Firewall
- **RRL** — Response Rate Limiting (DNS)
- **DMZ** — Demilitarised Zone (network segment)
- **OOB** — Out of Band
- **TTL** — Time To Live
- **SPIT** — Spam over Internet Telephony
- **SS7** — Signalling System No. 7
- **ISUP** — ISDN User Part (SS7)
- **TDM** — Time-Division Multiplexing
- **SSRC / CSRC** — Synchronisation / Contributing Source (RTP)
- **IVR** — Interactive Voice Response
- **DISA** — Direct Inward System Access
- **LCR** — Least-Cost Routing
- **CNAM** — Caller Name (database/service)
- **CPS** — Calls Per Second
- **KPI** — Key Performance Indicator
- **CSCF** — Call Session Control Function (IMS: P-/S-/I-CSCF); **HSS** — Home Subscriber Server
- **NNI** — Network-to-Network Interface
- **SFU / MCU** — Selective Forwarding Unit / Multipoint Control Unit (conferencing)
- **OSS** — Open-Source Software (in this course; note: in telco ops, OSS also = Operations Support System)
- **SIP methods** — INVITE, ACK, BYE, CANCEL, REGISTER, OPTIONS, REFER, SUBSCRIBE, NOTIFY, PRACK, UPDATE, MESSAGE, PUBLISH, INFO

## Standards bodies & authorities
- **IETF** — Internet Engineering Task Force; **BCP** — Best Current Practice (IETF)
- **ATIS** — Alliance for Telecommunications Industry Solutions
- **NIST** — (US) National Institute of Standards and Technology
- **NENA** — (US) National Emergency Number Association
- **GSMA** — GSM Association; **ENISA** — EU Agency for Cybersecurity
- **OWASP** — Open Worldwide Application Security Project; **PTES** — Penetration Testing Execution Standard
- **EECC / EENA** — European Electronic Communications Code / European Emergency Number Association

## Telephony KPIs, codecs & crypto (G5 cont.)
- **ASR** — Answer-Seizure Ratio; **ACD** — Average Call Duration; **PDD** — Post-Dial Delay
- **RTT** — Round-Trip Time; **E2E** — end-to-end
- **AMR / EVS** — Adaptive Multi-Rate / Enhanced Voice Services (mobile codecs)
- **CBR / VBR** — Constant / Variable Bit Rate
- **WSS / WS** — WebSocket Secure / WebSocket (SIP over WebSocket)
- **SAN** — Subject Alternative Name (X.509 certificate)
- **DH** — Diffie-Hellman (key exchange); **SHA-1** — Secure Hash Algorithm 1 (legacy; weak)
- **AAAA** — IPv6 address DNS record; **RFC 1918** — private IPv4 address ranges
