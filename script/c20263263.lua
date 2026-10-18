-- 王家魔族·分立混音伟人 (ID: 20263263)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合可以发动。这张卡的等级上升3星。那之后，对方场上有怪兽存在的场合，可以再从卡组把1张「王家魔族」魔法·陷阱卡加入手卡。
	-- 途径 1：通常召唤成功
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id) -- 效果①独立 HOPT
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- 途径 2：特殊召唤成功
	local e1_sp=e1:Clone()
	e1_sp:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1_sp)

	-- ②：这张卡被解放的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡返回手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,id+o*100) -- 效果②独立 HOPT（防撞车规范 id+o*100）
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end

-- ==================== 效果 ① 相关处理 ====================
function s.thfilter(c)
	return c:IsSetCard(0x321) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 严格遵守原生标准：杜绝 SetPossibleOperationInfo 与 CATEGORY_LVCHANGE
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 等级上升3星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(3)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)

		-- 那之后，对方场上有怪兽存在的场合，可以再从卡组把1张「王家魔族」魔法·陷阱卡加入手卡
		local opp_has_mon=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		if opp_has_mon and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

-- ==================== 效果 ② 相关处理 ====================
function s.thfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.thfilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter2,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter2,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end