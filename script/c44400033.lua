-- 水晶花·白冰晶 (ID: 44400033)
local s,id,o=GetID()
local SET_CRYSTAL_FLOWER=0x68f    -- 「水晶花」字段
local CARD_DINATO_TUNA=44400046   -- 「狄娜托·图娜」卡号
local CARD_POLYMERIZATION=24094653 -- 「融合」官方标准卡号

function s.initial_effect(c)
	-- 记录关联卡名与字段
	aux.AddCodeList(c,CARD_DINATO_TUNA,CARD_POLYMERIZATION)
	aux.AddSetNameMonsterList(c,SET_CRYSTAL_FLOWER)

	-- ①：自己场上存在「狄娜托·图娜」的场合才能发动。手卡这张卡特殊召唤或者当做持有以下效果的装备卡给自已场上的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	-- ②：自己场上的「狄娜托·图娜」以及那些怪兽装备的卡要被效果破坏的场合可以把墓地这张卡除外来作为代替。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)

	-- ③：这张卡被除外的下１个回合的准备阶段发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_REMOVE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- ①效果：手卡特召 或 当作装备卡装备
--------------------------------------------------------------------------------
function s.dinafilter(c)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA)
end

function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.dinafilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	else
		e:SetCategory(CATEGORY_EQUIP)
	end
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local op=e:GetLabel()
	if op==0 then
		-- 分支1：特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 分支2：当作装备卡装备
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc and Duel.Equip(tp,c,tc) then
			-- 装备限制
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetValue(s.eqlimit)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
			-- 装备卡持有效果：解放装备怪兽，检索 1 张装备卡与 1 张「融合」
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(id,3))
			e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
			e2:SetType(EFFECT_TYPE_IGNITION)
			e2:SetRange(LOCATION_SZONE)
			e2:SetCost(s.thcost)
			e2:SetTarget(s.thtg1)
			e2:SetOperation(s.thop1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2)
		end
	end
end

function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsReleasable() end
	Duel.Release(ec,REASON_COST)
end

function s.thfilter_eq(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end

function s.thfilter_poly(c)
	return c:IsCode(CARD_POLYMERIZATION) and c:IsAbleToHand()
end

function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter_eq,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.thfilter_poly,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter_eq),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter_poly),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if #g1==0 or #g2==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg1=g1:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	if #sg1==2 then
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg1)
	end
end

--------------------------------------------------------------------------------
-- ②效果：墓地除外代替破坏
--------------------------------------------------------------------------------
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and (c:IsCode(CARD_DINATO_TUNA) or s.eqcheck(c,tp))
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end

function s.eqcheck(c,tp)
	local tc=c:GetEquipTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsCode(CARD_DINATO_TUNA)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

--------------------------------------------------------------------------------
-- ③效果：除外后下个回合准备阶段发动回手
--------------------------------------------------------------------------------
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCountLimit(1,id+o*200)
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetCondition(s.thcon3)
	e1:SetTarget(s.thtg3)
	e1:SetOperation(s.thop3)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
	c:RegisterEffect(e1)
end

function s.thcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel()
end

function s.thtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.thop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end