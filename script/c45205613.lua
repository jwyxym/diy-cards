--战华之敏 庞元
local s,id=GetID()
function s.initial_effect(c)
	--①效果：召唤·特殊召唤的场合，把自己墓地的1只「战华」怪兽加入手卡或特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	--②效果：自己场上有「战华之德-刘玄」存在，怪兽的效果发动时，把自己手卡·场上1张永续魔法·永续陷阱卡送去墓地，那个效果无效
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

-- ①效果
function s.filter1(c,e,tp)
	return c:IsSetCard(0x137) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local b1=tc:IsAbleToHand()
		local b2=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		if b1 and b2 then
			if Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0 then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			else
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif b1 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		elseif b2 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

-- ②效果
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.liufilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.liufilter(c)
	return c:IsFaceup() and c:IsCode(40428851)
end

function s.costfilter2(c)
	return c:IsType(TYPE_CONTINUOUS) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToGraveAsCost()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

return s
