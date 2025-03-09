--莱欧斯小队-麻烦？
function c31280207.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	c:RegisterEffect(e1)
	--move
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31280207,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,31280207)
	e2:SetTarget(c31280207.mvtg)
	e2:SetOperation(c31280207.mvop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,11280207) 
	e3:SetCondition(c31280207.spcon) 
	e3:SetCost(c31280207.spcost)
	e3:SetTarget(c31280207.sptg)
	e3:SetOperation(c31280207.spop)
	c:RegisterEffect(e3) 
end
c31280207.SetCard_TnT_Lwsteam=true  
function c31280207.mvfil(c)
	return c:IsFaceup() and c:IsSetCard(0x3a21)
end
function c31280207.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc.SetCard_TnT_Lwsteam end
	if chk==0 then return Duel.IsExistingTarget(c31280207.mvfil,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end 
	Duel.SelectTarget(tp,c31280207.mvfil,tp,LOCATION_MZONE,0,1,1,nil) 
end
function c31280207.mvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp)
		or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	Duel.MoveSequence(tc,nseq)  
	e:GetHandler():SetCardTarget(tc)
end
function c31280207.mfilter(c,e,tp)  
	return c.SetCard_TnT_Lwsteam and c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp) and e:GetHandler():GetCardTarget():IsContains(c)
end
function c31280207.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()  
	g:KeepAlive() 
	e:SetLabelObject(g)
	return rp==1-tp and eg:IsExists(c31280207.mfilter,1,nil,e,tp)
end
function c31280207.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end  
	Duel.SendtoGrave(e:GetHandler(),REASON_COST) 
end 
function c31280207.sfilter(c,e,tp)
	return c:IsSetCard(0x3a21) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31280207.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c31280207.sfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) and Duel.IsPlayerCanDraw(tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end 
function c31280207.dckfil(c,e)
	local g=e:GetLabelObject()  
	return g and g:IsExists(Card.IsCode,1,nil,c:GetCode()) 
end 
function c31280207.spop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c31280207.sfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),g:GetClassCount(Card.GetCode))
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,ft,ft)
	if sg and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then 
		Duel.BreakEffect() 
		local x=Duel.GetMatchingGroup(c31280207.dckfil,tp,LOCATION_MZONE,0,nil,e):GetClassCount(Card.GetCode) 
		Duel.Draw(tp,x,REASON_EFFECT)
	end 
end

