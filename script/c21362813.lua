--魔诞 恶魔神官 巴洛
function c21362813.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FIEND),2)
	--special summon rule
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21362813,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,21362813+EFFECT_COUNT_CODE_OATH) 
	e1:SetCondition(c21362813.sprcon)
	e1:SetTarget(c21362813.sprtg)
	e1:SetOperation(c21362813.sprop)
	c:RegisterEffect(e1)
	--to hand/spsummon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS) 
	e1:SetCountLimit(1,31362813) 
	e1:SetCondition(c21362813.thcon)
	e1:SetOperation(c21362813.thop)
	c:RegisterEffect(e1) 
	--sp
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11362813)
	e2:SetTarget(c21362813.sptg)
	e2:SetOperation(c21362813.spop)
	c:RegisterEffect(e2)
	--gsp
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O) 
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetCountLimit(1,41362813)
	e3:SetCondition(c21362813.gspcon)
	e3:SetTarget(c21362813.gsptg)
	e3:SetOperation(c21362813.gspop)
	c:RegisterEffect(e3)
end
function c21362813.cgck(g,e,tp) 
	return Duel.GetLocationCountFromEx(tp,tp,g,e:GetHandler())>0 
end 
function c21362813.rlfil(c) 
	return c:IsReleasable() and c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0xba38)
end 
function c21362813.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(c21362813.rlfil,tp,LOCATION_MZONE,0,nil)
	return rg:CheckSubGroup(c21362813.cgck,2,2,e,tp) 
end
function c21362813.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(c21362813.rlfil,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=rg:SelectSubGroup(tp,c21362813.cgck,true,2,2,e,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function c21362813.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
function c21362813.pcfilter(c)
	return c:IsCode(21362800) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c21362813.tgfil(c)
	return c:IsSetCard(0xba38) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function c21362813.thcon(e,tp,eg,ep,ev,re,r,rp) 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362813.pcfilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_EXTRA,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil,21362800) and Duel.IsExistingMatchingCard(c21362813.tgfil,tp,LOCATION_DECK,0,1,nil)
	return b1 or b2 
end
function c21362813.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362813.pcfilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_EXTRA,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil,21362800) and Duel.IsExistingMatchingCard(c21362813.tgfil,tp,LOCATION_DECK,0,1,nil)
	if b1 or b2 then 
		Duel.Hint(HINT_CARD,0,21362813)
		if b2 then 
			local sg=Duel.SelectMatchingCard(tp,c21362813.tgfil,tp,LOCATION_DECK,0,1,1,nil) 
			Duel.SendtoGrave(sg,REASON_EFFECT) 
		else  
			local tc=Duel.SelectMatchingCard(tp,c21362813.pcfilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_EXTRA,0,1,1,nil):GetFirst()
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)  
		end 
	end
end
function c21362813.spfilter(c,e,tp)
	return c:IsSetCard(0xba38) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c21362813.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21362813.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c21362813.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c21362813.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c21362813.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c21362813.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp  
end
function c21362813.gspfil(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end 
function c21362813.gsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21362813.gspfil(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c21362813.gspfil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c21362813.gspfil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c21362813.gspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget() 
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then 
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end 
end 

