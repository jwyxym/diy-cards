--战华之负-才戏
local s,id=GetID()
function s.initial_effect(c)
	--① 受到战斗·效果伤害时，特召自身，对方1张卡送墓
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	--② 战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	
	--② 效果破坏
	local e2b=e2:Clone()
	e2b:SetCode(EVENT_DESTROYED)
	e2b:SetCondition(s.thcon2)
	c:RegisterEffect(e2b)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc and tc:IsRelateToEffect(e) then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end

--② 战斗破坏条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,1-tp)
end

function s.thcfilter(c,tp)
	return c:IsPreviousControler(tp) 
		and c:IsPreviousLocation(LOCATION_MZONE) 
		and c:IsReason(REASON_BATTLE)
end

--② 效果破坏条件
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter2,1,nil,1-tp)
end

function s.thcfilter2(c,tp)
	return c:IsPreviousControler(tp) 
		and c:IsPreviousLocation(LOCATION_MZONE) 
		and c:IsReason(REASON_EFFECT)
end

function s.thfilter(c)
	return c:IsSetCard(0x137) and c:IsAbleToDeck()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	if #g==3 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

return s
