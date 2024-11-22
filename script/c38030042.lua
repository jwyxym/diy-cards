--苍辉银河 埃列什基伽勒
local cm,m=GetID()
function c38030042.initial_effect(c)
		local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(cm.spcon)
	e1:SetTarget(cm.sptg)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m+1)
	e2:SetCost(cm.cost)
	e2:SetTarget(cm.target)
	e2:SetOperation(cm.activate)
	c:RegisterEffect(e2)
end
function cm.spfilter0(c)
	return c:IsSetCard(0x611) and c:IsAbleToRemoveAsCost()
end
function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.spfilter0,tp,LOCATION_GRAVE,0,2,nil)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(cm.spfilter0,tp,LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.texfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.texfilter2,tp,LOCATION_EXTRA,0,nil,e,tp) 
	local lvt={}
	local tc=g:GetFirst()
	while tc do
		local tlv=tc:GetLink()
		lvt[tlv]=tlv
		tc=g:GetNext()
	end
	local pc=1
	for i=1,8 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,1))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	local g=Duel.SelectMatchingCard(tp,cm.texfilter,tp,LOCATION_GRAVE,0,lv,lv,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(lv)
end
function cm.texfilter2(c,e,tp)
	local n=c:GetLink()
	local g=Duel.GetMatchingGroup(cm.texfilter,tp,LOCATION_GRAVE,0,1,nil)
	local m=#g+1
	return  c:IsType(TYPE_MONSTER) and c:IsSetCard(0x613)and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)  and m>n and n<6
end
function cm.texfilter(c)
	return c:IsAbleToRemoveAsCost()  and c:IsSetCard(0x611)
end
function cm.spfilter(c,e,tp)
	local n=c:GetLink()
	local g=Duel.GetMatchingGroup(cm.texfilter,tp,LOCATION_GRAVE,0,1,nil)
	local m=#g+1
	return c:IsSetCard(0x613) and c:IsType(TYPE_LINK) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and m>n and n<6
end
function cm.spfilter2(c,e,tp,n)
	return c:IsSetCard(0x613) and c:IsType(TYPE_LINK) and c:IsLink(n) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
	return  Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)  end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local n=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_LMATERIAL) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cm.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,n)
		local sc=g:GetFirst()
		if sc then
			sc:SetMaterial(nil)
			if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetTargetRange(1,0)
			e1:SetTarget(cm.counterfilter1)
			Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function cm.counterfilter1(e,c)
	return c:IsLocation(LOCATION_EXTRA) and c:GetOriginalType()&TYPE_LINK>0 and not c:IsSetCard(0x613)
end