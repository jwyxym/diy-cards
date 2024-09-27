--闪耀龙女外包
if not pcall(function() require("expansions/script/alanpa") end) then require("script/alanpa") end
local deck = "The shining ☆ dragon young girl"
Debug.Message("Welcome to use my Deck：" .. deck .. ".")

---------------------------------------------------------------"库函数"------------------------------------------------------------------
--卡函数
function Card.IsSn(c)
    return c:IsSetCard(0xfae)
end
function lc.shine_monsterfilter(c)
	return c:IsSn() and c:IsType(lptyp.m)
end
function lc.thf1(c)
	return c:IsSn() and c:IsType(lptyp.m) and c:IsAbleToHand()
end
function lc.thf2(c)
	return c:IsSn() and c:IsType(lptyp.st) and c:IsAbleToHand()
end
function lc.thf(c)
	return c:IsSn() and c:IsAbleToHand()
end
function lc.tunerf(c)
	return c:IsSn() and c:IsType(lptyp.tun)
end
function lc.spf(c,e,tp)
	return c:IsSn() and c:IsLevel(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function lc.spf1(c,e,tp)
	return c:IsSn() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function lc.sumf(c)
	return c:IsSummonable(true,nil) and c:IsSn()
end
function lc.daglinkf(c)
    return c:IsRace(lprac.dag) and c:IsType(lptyp.link)
end
--组函数
function lg.dragon_linkedhalfgroup(tp)
    local g=lf.D("GMG",lc.daglinkf,tp,"M",0,nil)
    local rlg=lg.GetGroupLinkedHalfLineGroup(g)
    return rlg
end
--效果函数
function le.tohand_sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=lf.E(e,"GH")
	if chk==0 then return c:IsAbleToHand() and lf.D("GMZC",tp,c)>0 and lf.D("EMC",lc.spf,tp,"HG",0,1,nil,e,tp) end
	lf.D("SO",0,"TH",c,1,0,0)
    lf.D("SO",0,"SP",nil,1,tp,"HG")
end
function le.tohand_spop(e,tp,eg,ep,ev,re,r,rp)
	local c=lf.E(e,"GH")
	if c:IsRelateToEffect(e) and lf.D("TH",c,nil,rea.eff)~=0
		and c:Isloc("H") and lf.D("GLC",tp,lp.ran["M"])>0 then
		lf.D("HINT","S",tp,"SP")
		local g=lf.D("SMC",tp,lc.spf,tp,"HG",0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			lf.D("SP",g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function le.small_blue_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return lf.D("PCDD",tp,3) end
	lf.D("SO",0,"DD",nil,0,tp,3)
end
function le.small_blue_op(e,tp,eg,ep,ev,re,r,rp)
	lf.D("DD",tp,3,rea.eff)
end
function le.ovg_con(e,tp,eg,ep,ev,re,r,rp,typ)
	return lf.E(e,"GH"):GetOverlayGroup():IsExists(Card.IsType,1,nil,typ)
end
----------------------------------------------------------------------支持函数
function lf.shine_sp_sum(c,des,cat,ctl,tg,op,rc)
    return lf.STO(c,des,cat,"SP","DE",nil,ctl,nil,nil,tg,op,rc,nil,nil,nil) and lf.STO(c,des,cat,"SS","DE",nil,ctl,nil,nil,tg,op,rc,nil,nil,nil)
end
function lf.shine_tohsnd_sp(c,des,ctl,rc)
    return lf.FTO(c,des,"SPTH","BS",nil,"M",ctl,nil,nil,le.tohand_sptg,le.tohand_spop,rc,nil,nil,nil) and lf.FTO(c,des,"SPTH","SB",nil,"M",ctl,nil,nil,le.tohand_sptg,le.tohand_spop,rc,nil,nil,nil)
end
function lf.other_sum_sp_effect(c,des,cat,ran,ctl,con,tg,op,rc)
    return lf.FTO(c,des,cat,"SP","DE",ran,ctl,con,nil,tg,op,rc,nil,nil,nil) and lf.FTO(c,des,cat,"SS","DE",ran,ctl,con,nil,tg,op,rc,nil,nil,nil)
end
function lf.sp_proc(c,ran,val,ctl,con,rc)
    return lf.F(c,nil,"SPOC","OE",ran,nil,val,ctl,con,nil,nil,rc,nil,nil,nil)
end
function lf.cannot_sp(c,tran1,tran2,val,res)
    local e1=lf.E(nil,"CRE",c)
	lf.E(e1,"TYP","F")
	lf.E(e1,"PRO","PY")
	lf.E(e1,"COD","CNP")
	e1:SetReset(res)
	lf.E(e1,"TRAN",tran1,tran2)
	lf.E(e1,"TG",val)
	lf.D("RE",e1,tp)
    return e1
end
function lf.player_continuous(c,cod,ran,con,op,rc,res)
    return lf.FC(c,nil,cod,"PY",ran,nil,con,op,rc,res,nil,nil)
end
function lf.cannot_th(c,tran1,tran2,val,res)
    local e1=lf.E(nil,"CRE",c)
	lf.E(e1,"TYP","F")
	lf.E(e1,"PRO","PY")
	lf.E(e1,"COD","CNTH")
	e1:SetReset(res)
	lf.E(e1,"TRAN",tran1,tran2)
	lf.E(e1,"TG",val)
	lf.D("RE",e1,tp)
    return e1
end
function lf.shine_qo_effect(c,des1,cat1,pro1,ctl1,con1,cos1,tg1,op1,rc,des2,cat2,pro2,ctl2,con2,cos2,tg2,op2)
    return lf.QO(c,des1,cat1,nil,pro1,"H",ctl1,con1,cos1,tg1,op1,rc,nil,nil,nil) and lf.QO(c,des2,cat2,nil,pro2,"M",ctl2,con2,cos2,tg2,op2,rc,nil,nil,nil)
end
function lf.splimit_effect(c,ran,val,rc)
    return lf.S(c,nil,"ESC","OE",ran,val,nil,nil,nil,rc,nil,nil,nil)
end
function lf.cannot_dis_sp(c,sptyp,rc)
    return lf.S(c,nil,"CNDP","OE",nil,nil,nil,le.sptypcon(sptyp),nil,rc,nil,nil,nil)
end