--束约炮固定式
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.GetLevelOrRankOrLink(c)
	if c:IsLevelAbove(1) then
		return c:GetLevel()
	elseif c:IsRankAbove(1) then
		return c:GetRank()
	elseif c:IsLinkAbove(1) then
		return c:GetLink()
	end
	return NULL_VALUE 
end
function s.GetLevelOrRank(c)
	if c:IsLevelAbove(1) then
		return c:GetLevel()
	elseif c:IsRankAbove(1) then
		return c:GetRank()
	end
	return NULL_VALUE 
end
function s.penfilter(c)
	return c:IsAbleToRemove() and s.GetLevelOrRank(c)>0
end
function s.rescon(sg,lv)
	return sg:GetSum(s.GetLevelOrRank)==lv and sg:IsExists(Card.IsAbleToRemove,1,nil)
end
function s.cfilter(c,pg)
	local lv=s.GetLevelOrRankOrLink(c)
	return c:IsFaceup() and lv>0 and pg:CheckSubGroup(s.rescon,2,2,lv)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local pg=Duel.GetMatchingGroup(s.penfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil,pg) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_EXTRA)
end
function s.rfilter(c,ls,rs)
	return c:IsType(TYPE_XYZ) and c:GetRank()>ls and c:GetRank()<rs
		and c:IsAbleToRemove()
end
function s.rfilter2(c,tp)
	local lv=s.GetLevelOrRankOrLink(c)
	return c:IsFaceup() and lv>0 and c:IsAbleToRemove(1-tp,POS_FACEUP,REASON_RULE)
end
function s.rescon2(sg,lv)
	return sg:GetSum(s.GetLevelOrRank)==lv
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local pg=Duel.GetMatchingGroup(s.penfilter,tp,LOCATION_EXTRA,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil,pg):GetFirst()
	if not tc then return end
	local plv=s.GetLevelOrRankOrLink(tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cg=pg:SelectSubGroup(tp,s.rescon,false,2,2,plv)
	Duel.ConfirmCards(1-tp,cg)
	local pc1=cg:GetFirst()
	local pc2=cg:GetNext()
	local ls,rs=pc1:GetLeftScale(),pc2:GetLeftScale()
	if ls>rs then ls,rs=rs,ls end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rc=cg:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil):GetFirst()
	local rlv=s.GetLevelOrRank(rc)
	if not rc or Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)<0 or not rc:IsLocation(LOCATION_REMOVED) then return end
	if Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_EXTRA,0,1,nil,ls,rs)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local xyz=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_EXTRA,0,1,1,nil,ls,rs):GetFirst()
		local rk=xyz:GetRank()
		if not xyz or Duel.Remove(xyz,POS_FACEUP,REASON_EFFECT)<0 or not xyz:IsLocation(LOCATION_REMOVED) then return end 
		if not Duel.IsPlayerCanRemove(1-tp) then return end
		local lv=rk*rlv
		local rg=Duel.GetMatchingGroup(s.rfilter2,tp,0,LOCATION_MZONE,nil,tp)
		if #rg==0 then return end
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg=rg:SelectSubGroup(1-tp,s.rescon2,false,1,#rg,lv)
		if sg and #sg>0 then Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,1-tp) end
	end
end