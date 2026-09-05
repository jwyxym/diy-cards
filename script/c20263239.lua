-- 光天使 辉弓 (ID: 20263239)
local s,id,o=GetID()
local SET_STAR_SERAPH=0x86 -- 「光天使」官方字段代码
local EFFECT_DOUBLE_XMATERIAL=EFFECT_DOUBLE_XMATERIAL or 511001225

function s.initial_effect(c)
	-- ①：从卡组·墓地加入手卡的场合：手卡特召自身，卡组检索非同名「光天使」怪兽 (HOPT: id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	-- ②：召唤·特殊召唤的场合：卡组·墓地把1张「光天使」怪兽在卡组最上方放置 (HOPT: id+o*100)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o*100)
	e2:SetTarget(s.toptg2)
	e2:SetOperation(s.topop2)
	c:RegisterEffect(e2)
	local e2_sp=e2:Clone()
	e2_sp:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2_sp)

	-- ③：作为3只以上素材的光属性超量怪兽超量召唤的素材的场合，这张卡可以作为2只数量的超量素材
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e3:SetTarget(s.xyztg)
	e3:SetValue(s.xyzval)
	c:RegisterEffect(e3)
end

-- ==================== ① 效果：加入手卡特召自身 + 检索非同名「光天使」 ====================
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsContains(c) and c:IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE)
end

function s.thfilter(c)
	return c:IsSetCard(SET_STAR_SERAPH) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

-- ==================== ② 效果：卡组·墓地「光天使」怪兽卡组顶置 ====================
function s.topfilter(c)
	return c:IsSetCard(SET_STAR_SERAPH) and c:IsType(TYPE_MONSTER)
end

function s.toptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.topfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.topop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.topfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsLocation(LOCATION_DECK) then
			-- 卡组置顶：先洗牌，再平移到最顶端并展示确认
			Duel.ShuffleDeck(tp)
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			Duel.ConfirmDecktop(tp,1)
		else
			-- 墓地置顶：直接送回卡组最上方
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end

-- ==================== ③ 效果：作为2只数量超量素材（光属性3体以上超量） ====================
function s.xyztg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.xyzval(e,c)
	return 2
end