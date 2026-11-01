-- 无际日蚀蛾 埃拉 (ID: 23600075)
local s,id,o=GetID()
local SET_ECLIPSE = 0xd92

function s.initial_effect(c)
	-- 超量召唤手续：昆虫族9星怪兽×3只以上
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),9,3,nil,nil,99)

	-- ①：把这张卡1个超量素材取除才能发动。从自己的卡组·墓地·除外状态把1张「天蚀」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id) -- ①效果独立 HOPT
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)

	-- ②：这张卡有昆虫族超量怪兽在作为超量素材的场合，得到以下效果。
	-- ●只要这张卡在怪兽区域存在，对方不能把自己场上的昆虫族超量怪兽解放，也不能作为融合·同调·超量·连接召唤的素材。
	-- 抗解放（上级召唤解放封锁）
	local e2_rel1=Effect.CreateEffect(c)
	e2_rel1:SetType(EFFECT_TYPE_FIELD)
	e2_rel1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2_rel1:SetRange(LOCATION_MZONE)
	e2_rel1:SetTargetRange(LOCATION_MZONE,0)
	e2_rel1:SetCondition(s.protcon)
	e2_rel1:SetTarget(s.prottg)
	e2_rel1:SetValue(s.reval)
	c:RegisterEffect(e2_rel1)
	-- 抗解放（特殊召唤/卡的效果解放封锁，阻断坏兽/熔岩魔神/球体形）
	local e2_rel2=e2_rel1:Clone()
	e2_rel2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2_rel2)

	-- 对方不能作为融合·同调·超量·连接素材
	local mat_codes={EFFECT_CANNOT_BE_FUSION_MATERIAL,EFFECT_CANNOT_BE_SYNCHRO_MATERIAL,EFFECT_CANNOT_BE_XYZ_MATERIAL,EFFECT_CANNOT_BE_LINK_MATERIAL}
	for _,code in ipairs(mat_codes) do
		local e_mat=Effect.CreateEffect(c)
		e_mat:SetType(EFFECT_TYPE_FIELD)
		e_mat:SetCode(code)
		e_mat:SetRange(LOCATION_MZONE)
		e_mat:SetTargetRange(LOCATION_MZONE,0)
		e_mat:SetCondition(s.protcon)
		e_mat:SetTarget(s.prottg)
		e_mat:SetValue(s.matval)
		c:RegisterEffect(e_mat)
	end

	-- ③：对方的结束阶段，以自己的墓地·除外状态的2只昆虫族怪兽为对象才能发动。
	-- 那之内的1只加入手卡，另1只回到卡组最下面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*100) -- ③效果独立 HOPT（防撞车规范 id+o*100）
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end

-- ==================== ① 效果：卡组·墓地·除外检索 ====================
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.thfilter(c)
	return c:IsSetCard(SET_ECLIPSE) and c:IsAbleToHand()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,loc,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,loc)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,loc,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- ==================== ② 效果：抗解放与抗素材光环 ====================
function s.matfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsType(TYPE_XYZ)
end

function s.protcon(e)
	-- 持有昆虫族超量怪兽作为超量素材时生效
	return e:GetHandler():GetOverlayGroup():IsExists(s.matfilter,1,nil)
end

function s.prottg(e,c)
	-- 保护自己场上的昆虫族超量怪兽（包含自身）
	return c:IsRace(RACE_INSECT) and c:IsType(TYPE_XYZ)
end

function s.reval(e,re,r,rp)
	-- 对方不能解放（阻断对方进行的上级召唤、坏兽出场及卡的效果解放）
	return rp==1-e:GetHandlerPlayer()
end

function s.matval(e,c)
	-- 对方不能作为融合·同调·超量·连接素材（超融合、闭界之冥神等封锁）
	return not c or c:GetControler()==1-e:GetHandlerPlayer()
end

-- ==================== ③ 效果：对方结束阶段回收与弹底（已彻底修复） ====================
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end

function s.tdfilter(c)
	return c:IsRace(RACE_INSECT) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and (c:IsAbleToHand() or c:IsAbleToDeck())
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local loc=LOCATION_GRAVE+LOCATION_REMOVED
	if chk==0 then
		return Duel.IsExistingTarget(s.tdfilter,tp,loc,0,2,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,loc,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 彻底剔除 EdoPRO 私货 GetTargetCards，使用标准 ocgcore 链条对象获取
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg then return end
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #g~=2 then return end

	-- 选其中 1 只加入手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local hg=g:FilterSelect(tp,aux.NecroValleyFilter(Card.IsAbleToHand),1,1,nil)
	local tc_hand=hg:GetFirst()
	if tc_hand and Duel.SendtoHand(tc_hand,nil,REASON_EFFECT)>0 then
		if tc_hand:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,tc_hand)
		end
		g:RemoveCard(tc_hand)

		-- 另 1 只回到卡组最下面（第三参数 1 即代表 SEQ_DECKBOTTOM 底层规范数值）
		local tc_deck=g:GetFirst()
		if tc_deck then
			Duel.SendtoDeck(tc_deck,nil,1,REASON_EFFECT)
		end
	end
end